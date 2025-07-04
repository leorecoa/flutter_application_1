provider "aws" {
  region = var.primary_region
}

# CloudFront Distribution
resource "aws_cloudfront_distribution" "frontend" {
  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"
  price_class         = "PriceClass_All"
  wait_for_deployment = false
  
  aliases = ["app.${var.domain_name}"]

  # Primary S3 Origin
  origin {
    domain_name = "${var.app_name}-frontend-${var.environment}-${var.primary_region}.s3.amazonaws.com"
    origin_id   = "S3-${var.app_name}-frontend-${var.environment}-primary"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.frontend.cloudfront_access_identity_path
    }
  }

  # Secondary S3 Origin (failover)
  origin {
    domain_name = "${var.app_name}-frontend-${var.environment}-${var.secondary_region}.s3.amazonaws.com"
    origin_id   = "S3-${var.app_name}-frontend-${var.environment}-secondary"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.frontend.cloudfront_access_identity_path
    }
  }

  # Origin Group for failover
  origin_group {
    origin_id = "S3-Group"

    failover_criteria {
      status_codes = [403, 404, 500, 502]
    }

    member {
      origin_id = "S3-${var.app_name}-frontend-${var.environment}-primary"
    }

    member {
      origin_id = "S3-${var.app_name}-frontend-${var.environment}-secondary"
    }
  }

  # Default Cache Behavior
  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = "S3-Group"

    forwarded_values {
      query_string = true
      cookies {
        forward = "none"
      }
      headers = ["Origin", "Access-Control-Request-Headers", "Access-Control-Request-Method"]
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
    compress               = true

    # Lambda@Edge for regional customization
    lambda_function_association {
      event_type   = "viewer-request"
      lambda_arn   = aws_lambda_function.edge_regional_redirect.qualified_arn
      include_body = false
    }
  }

  # SPA Routing - Handle all paths
  ordered_cache_behavior {
    path_pattern     = "/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = "S3-Group"

    forwarded_values {
      query_string = true
      cookies {
        forward = "none"
      }
      headers = ["Origin", "Access-Control-Request-Headers", "Access-Control-Request-Method"]
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
    compress               = true
  }

  # Geo Restrictions
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  # SSL Certificate
  viewer_certificate {
    acm_certificate_arn      = var.acm_certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  tags = {
    Name        = "${var.app_name}-cloudfront-${var.environment}"
    Environment = var.environment
  }
}

# CloudFront Origin Access Identity
resource "aws_cloudfront_origin_access_identity" "frontend" {
  comment = "OAI for ${var.app_name} frontend - ${var.environment}"
}

# Lambda@Edge for Regional Customization
data "archive_file" "lambda_edge_code" {
  type        = "zip"
  source_file = "${path.module}/lambda-edge/regional-redirect.js"
  output_path = "${path.module}/lambda-edge/regional-redirect.zip"
}

resource "aws_lambda_function" "edge_regional_redirect" {
  provider         = aws
  function_name    = "${var.app_name}-edge-regional-redirect-${var.environment}"
  filename         = data.archive_file.lambda_edge_code.output_path
  source_code_hash = data.archive_file.lambda_edge_code.output_base64sha256
  role             = aws_iam_role.lambda_edge.arn
  handler          = "regional-redirect.handler"
  runtime          = "nodejs18.x"
  publish          = true
  timeout          = 5
  memory_size      = 128

  tags = {
    Name        = "${var.app_name}-edge-regional-redirect-${var.environment}"
    Environment = var.environment
  }
}

# IAM Role for Lambda@Edge
resource "aws_iam_role" "lambda_edge" {
  name = "${var.app_name}-lambda-edge-role-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = [
            "lambda.amazonaws.com",
            "edgelambda.amazonaws.com"
          ]
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "lambda_edge" {
  name = "${var.app_name}-lambda-edge-policy-${var.environment}"
  role = aws_iam_role.lambda_edge.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Effect   = "Allow"
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

# S3 Bucket Policies
resource "aws_s3_bucket_policy" "frontend_primary" {
  bucket = "${var.app_name}-frontend-${var.environment}-${var.primary_region}"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = "s3:GetObject"
        Effect   = "Allow"
        Resource = "arn:aws:s3:::${var.app_name}-frontend-${var.environment}-${var.primary_region}/*"
        Principal = {
          AWS = aws_cloudfront_origin_access_identity.frontend.iam_arn
        }
      }
    ]
  })
}

resource "aws_s3_bucket_policy" "frontend_secondary" {
  bucket = "${var.app_name}-frontend-${var.environment}-${var.secondary_region}"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = "s3:GetObject"
        Effect   = "Allow"
        Resource = "arn:aws:s3:::${var.app_name}-frontend-${var.environment}-${var.secondary_region}/*"
        Principal = {
          AWS = aws_cloudfront_origin_access_identity.frontend.iam_arn
        }
      }
    ]
  })
}
provider "aws" {
  alias  = "primary"
  region = var.primary_region
}

provider "aws" {
  alias  = "secondary"
  region = var.secondary_region
}

# DynamoDB Global Table
resource "aws_dynamodb_table" "primary" {
  provider         = aws.primary
  name             = "${var.app_name}-${var.environment}"
  billing_mode     = "PAY_PER_REQUEST"
  hash_key         = "PK"
  range_key        = "SK"
  stream_enabled   = true
  stream_view_type = "NEW_AND_OLD_IMAGES"

  attribute {
    name = "PK"
    type = "S"
  }

  attribute {
    name = "SK"
    type = "S"
  }

  attribute {
    name = "GSI1PK"
    type = "S"
  }

  attribute {
    name = "GSI1SK"
    type = "S"
  }

  global_secondary_index {
    name            = "GSI1"
    hash_key        = "GSI1PK"
    range_key       = "GSI1SK"
    projection_type = "ALL"
  }

  replica {
    region_name = var.secondary_region
  }

  tags = {
    Environment = var.environment
    Application = var.app_name
  }
}

# API Gateway - Primary Region
resource "aws_api_gateway_rest_api" "primary" {
  provider    = aws.primary
  name        = "${var.app_name}-api-${var.environment}"
  description = "API Gateway for ${var.app_name} - ${var.environment}"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

# API Gateway - Secondary Region
resource "aws_api_gateway_rest_api" "secondary" {
  provider    = aws.secondary
  name        = "${var.app_name}-api-${var.environment}"
  description = "API Gateway for ${var.app_name} - ${var.environment}"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

# Route 53 Health Checks
resource "aws_route53_health_check" "primary" {
  provider          = aws.primary
  fqdn              = "${aws_api_gateway_rest_api.primary.id}.execute-api.${var.primary_region}.amazonaws.com"
  port              = 443
  type              = "HTTPS"
  resource_path     = "/health"
  failure_threshold = 3
  request_interval  = 30

  tags = {
    Name = "${var.app_name}-primary-health-check"
  }
}

resource "aws_route53_health_check" "secondary" {
  provider          = aws.primary
  fqdn              = "${aws_api_gateway_rest_api.secondary.id}.execute-api.${var.secondary_region}.amazonaws.com"
  port              = 443
  type              = "HTTPS"
  resource_path     = "/health"
  failure_threshold = 3
  request_interval  = 30

  tags = {
    Name = "${var.app_name}-secondary-health-check"
  }
}

# Route 53 Failover Records
resource "aws_route53_record" "primary" {
  provider = aws.primary
  zone_id  = var.route53_zone_id
  name     = "api.${var.domain_name}"
  type     = "A"

  failover_routing_policy {
    type = "PRIMARY"
  }

  set_identifier  = "primary"
  health_check_id = aws_route53_health_check.primary.id

  alias {
    name                   = "${aws_api_gateway_rest_api.primary.id}.execute-api.${var.primary_region}.amazonaws.com"
    zone_id                = aws_api_gateway_rest_api.primary.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "secondary" {
  provider = aws.primary
  zone_id  = var.route53_zone_id
  name     = "api.${var.domain_name}"
  type     = "A"

  failover_routing_policy {
    type = "SECONDARY"
  }

  set_identifier  = "secondary"
  health_check_id = aws_route53_health_check.secondary.id

  alias {
    name                   = "${aws_api_gateway_rest_api.secondary.id}.execute-api.${var.secondary_region}.amazonaws.com"
    zone_id                = aws_api_gateway_rest_api.secondary.zone_id
    evaluate_target_health = true
  }
}

# S3 Buckets for Frontend
resource "aws_s3_bucket" "frontend_primary" {
  provider = aws.primary
  bucket   = "${var.app_name}-frontend-${var.environment}-${var.primary_region}"

  tags = {
    Name        = "${var.app_name} Frontend - ${var.environment} - ${var.primary_region}"
    Environment = var.environment
  }
}

resource "aws_s3_bucket" "frontend_secondary" {
  provider = aws.secondary
  bucket   = "${var.app_name}-frontend-${var.environment}-${var.secondary_region}"

  tags = {
    Name        = "${var.app_name} Frontend - ${var.environment} - ${var.secondary_region}"
    Environment = var.environment
  }
}

# S3 Bucket Replication
resource "aws_s3_bucket_replication_configuration" "frontend_replication" {
  provider   = aws.primary
  depends_on = [aws_s3_bucket_versioning.frontend_primary]
  
  role   = aws_iam_role.replication.arn
  bucket = aws_s3_bucket.frontend_primary.id

  rule {
    id     = "frontend-replication"
    status = "Enabled"

    destination {
      bucket        = aws_s3_bucket.frontend_secondary.arn
      storage_class = "STANDARD"
    }
  }
}

resource "aws_s3_bucket_versioning" "frontend_primary" {
  provider = aws.primary
  bucket   = aws_s3_bucket.frontend_primary.id
  
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_versioning" "frontend_secondary" {
  provider = aws.secondary
  bucket   = aws_s3_bucket.frontend_secondary.id
  
  versioning_configuration {
    status = "Enabled"
  }
}

# IAM Role for S3 Replication
resource "aws_iam_role" "replication" {
  provider = aws.primary
  name     = "${var.app_name}-s3-replication-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "s3.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "replication" {
  provider = aws.primary
  name     = "${var.app_name}-s3-replication-policy-${var.environment}"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:GetReplicationConfiguration",
          "s3:ListBucket"
        ]
        Effect   = "Allow"
        Resource = [aws_s3_bucket.frontend_primary.arn]
      },
      {
        Action = [
          "s3:GetObjectVersionForReplication",
          "s3:GetObjectVersionAcl",
          "s3:GetObjectVersionTagging"
        ]
        Effect   = "Allow"
        Resource = ["${aws_s3_bucket.frontend_primary.arn}/*"]
      },
      {
        Action = [
          "s3:ReplicateObject",
          "s3:ReplicateDelete",
          "s3:ReplicateTags"
        ]
        Effect   = "Allow"
        Resource = ["${aws_s3_bucket.frontend_secondary.arn}/*"]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "replication" {
  provider   = aws.primary
  role       = aws_iam_role.replication.name
  policy_arn = aws_iam_policy.replication.arn
}
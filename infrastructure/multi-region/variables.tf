variable "app_name" {
  description = "Name of the application"
  type        = string
  default     = "agenda-facil"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "dev"
}

variable "primary_region" {
  description = "Primary AWS region"
  type        = string
  default     = "us-east-1"
}

variable "secondary_region" {
  description = "Secondary AWS region"
  type        = string
  default     = "us-west-2"
}

variable "domain_name" {
  description = "Domain name for the application"
  type        = string
  default     = "agendafacil.com"
}

variable "route53_zone_id" {
  description = "Route 53 hosted zone ID"
  type        = string
}

variable "lambda_functions" {
  description = "List of Lambda functions to deploy in both regions"
  type        = list(string)
  default     = ["auth", "appointments", "services", "tenant"]
}
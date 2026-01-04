variable "aws_region" {
  type        = string
  description = "AWS region where all resources will be created."
  default     = "us-east-2"

  validation {
    condition     = var.aws_region == "us-east-2"
    error_message = "This project is pinned to us-east-2. Do not change the region."
  }
}

variable "name_prefix" {
  type        = string
  description = "Prefix used for naming all resources."
  default     = "tf-portfolio"
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to all taggable resources."
  default = {
    Project = "terraform-iac"
    Owner   = "kevin"
    Env     = "dev"
  }
}

variable "log_retention_days" {
  type        = number
  description = "CloudWatch Logs retention in days."
  default     = 7

  validation {
    condition     = var.log_retention_days >= 1 && var.log_retention_days <= 365
    error_message = "log_retention_days must be between 1 and 365."
  }
}

variable "lambda_function_name" {
  type        = string
  description = "Name of the Lambda function."
  default     = "tf-portfolio-hello"
}


variable "aws_region" {
  type        = string
  description = "AWS region for backend resources."
  default     = "us-east-2"
}

variable "bucket_name" {
  type        = string
  description = "S3 bucket name for Terraform remote state."
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to all backend resources."
  default = {
    Project = "terraform-iac"
    Owner   = "kevin"
    Env     = "dev"
  }
}


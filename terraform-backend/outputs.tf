output "bucket_name" {
  value       = aws_s3_bucket.tfstate.bucket
  description = "S3 bucket used for Terraform remote state."
}

output "dynamodb_table_name" {
  value       = aws_dynamodb_table.locks.name
  description = "DynamoDB table used for state locking."
}


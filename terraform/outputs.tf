output "lambda_execution_role_name" {
  value       = aws_iam_role.lambda_exec.name
  description = "IAM role name used by the Lambda function."
}

output "lambda_execution_role_arn" {
  value       = aws_iam_role.lambda_exec.arn
  description = "IAM role ARN used by the Lambda function."
}

output "aws_account_id" {
  value       = data.aws_caller_identity.current.account_id
  description = "AWS account ID Terraform is authenticated to."
}

output "aws_region" {
  value       = data.aws_region.current.name
  description = "AWS region Terraform is targeting."
}

output "lambda_log_group_name" {
  value       = aws_cloudwatch_log_group.lambda.name
  description = "CloudWatch log group for the Lambda function."
}

output "lambda_function_name" {
  value       = aws_lambda_function.hello.function_name
  description = "Deployed Lambda function name."
}

output "lambda_function_arn" {
  value       = aws_lambda_function.hello.arn
  description = "Deployed Lambda function ARN."
}

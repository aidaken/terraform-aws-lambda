provider "aws" {
  region = var.aws_region

  default_tags {
    tags = var.tags
  }
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

resource "aws_iam_role" "lambda_exec" {
  name = "${var.name_prefix}-lambda-exec"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_cloudwatch_log_group" "lambda" {
  name              = "/aws/lambda/${var.lambda_function_name}"
  retention_in_days = var.log_retention_days
}

resource "aws_iam_policy" "lambda_logs" {
  name        = "${var.name_prefix}-lambda-logs"
  description = "Least-privilege policy for Lambda to write CloudWatch Logs."

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCreateLogGroup"
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup"
        ]
        Resource = "*"
      },
      {
        Sid    = "AllowWriteToProjectLogGroup"
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = [
          aws_cloudwatch_log_group.lambda.arn,
          "${aws_cloudwatch_log_group.lambda.arn}:log-stream:*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_logs_attach" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = aws_iam_policy.lambda_logs.arn
}

resource "aws_lambda_function" "hello" {
  function_name = var.lambda_function_name
  role          = aws_iam_role.lambda_exec.arn

  runtime = "python3.12"
  handler = "handler.handler"

  filename         = "${path.module}/../lambda/dist/lambda.zip"
  source_code_hash = filebase64sha256("${path.module}/../lambda/dist/lambda.zip")

  timeout     = 3
  memory_size = 128

  environment {
    variables = {
      SERVICE = var.lambda_function_name
    }
  }

  depends_on = [
    aws_cloudwatch_log_group.lambda
  ]
}


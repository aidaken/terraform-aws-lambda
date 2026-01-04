#Terraform AWS Lambda Infrastructure
This repository is a small but deliberate example of how I build AWS infrastructure using Terraform instead of manual AWS Console setup. The goal of this project is not complexity, but correctness: defining infrastructure clearly, securing it properly, and managing its lifecycle safely through code.
Manually created AWS infrastructure is hard to reproduce, review, and safely change. This project replaces console-based setup with a fully defined, verifiable infrastructure managed through code.

##What I built
The main infrastructure lives in the terraform/ directory and provisions a simple AWS Lambda function along with everything it needs to run correctly.
The Lambda uses a dedicated IAM role, a custom IAM policy, and an explicitly created CloudWatch log group. All resources are created, updated, and destroyed only through Terraform. Nothing is configured manually in the AWS Console.
The Lambda code itself is intentionally minimal. It exists to demonstrate how infrastructure, permissions, and logging work together, not to showcase application logic.

##How I approached the problem
I treated this like a real system, even though it is small.
Instead of relying on AWS defaults, I defined resources explicitly. The CloudWatch log group is created in Terraform so I can control retention and avoid unbounded log growth. IAM permissions are scoped narrowly so the Lambda can only write logs to its own log group. The function runs with the smallest reasonable memory and timeout settings.
After applying Terraform, I verified the results using the AWS CLI to confirm that the role, policy, log group, and Lambda behaved exactly as intended. I don’t assume infrastructure is correct just because terraform apply succeeded.

##Terraform state and safety
The terraform-backend/ directory contains a separate Terraform project used to create a remote backend for Terraform state. This backend uses S3 for state storage and DynamoDB for state locking.
This prevents concurrent Terraform runs from corrupting state and reflects how Terraform is used in team environments and CI/CD pipelines. Backend configuration values are not committed to the repository and are provided locally when needed.

##Cost awareness
This project is designed to be inexpensive by default. Lambda runs on a pay-per-request model, logs have a short retention period, and backend resources are only active during Terraform operations.
All infrastructure can be removed completely with terraform destroy, leaving no running resources or ongoing costs.

##How this can evolve
Although this project deploys a simple Lambda, the structure is intentional. The same foundation can evolve into an event-driven system, such as a data ingestion pipeline triggered by S3 events or other AWS services.
I am currently focused on Cloud Engineering, with plans to move toward Cloud Data Engineering, and this project serves as a clean starting point for that transition.

##Why this project exists
I built this project to practice writing infrastructure the way I would want it handled in a real team: reproducible, reviewable, secure, and easy to clean up.
It’s not about building fast. It’s about building safely and understanding what actually exists in the cloud at any moment.

# Architecture

## What This Project Builds

This repository demonstrates Infrastructure as Code using Terraform to provision a serverless workload on AWS. The goal is to show how infrastructure can be version-controlled, reviewed, and deployed like application code—replacing manual console work with a repeatable, auditable process.

The project creates a minimal but production-minded Lambda function with proper IAM permissions and logging. Everything is managed through Terraform, meaning you can destroy and recreate the entire stack with a single command. No clicking through AWS console wizards, no "it works on my machine" problems, and no wondering what someone changed last Tuesday.

## The Core Infrastructure

The main application infrastructure lives in the `terraform/` directory and consists of five AWS resources working together. At the center is a Lambda function that needs permissions to execute and a place to write logs. The IAM role provides the Lambda's identity—it's what the Lambda "becomes" when it runs. Attached to that role is a custom IAM policy that grants the minimal log permissions needed (CreateLogGroup defensively + write logs to one log group).

That log group is created explicitly rather than letting AWS generate it automatically. This gives us control over retention (set to 7 days) and ensures the IAM policy can be scoped tightly to just this group. The Lambda itself is packaged as a zip file containing Python code, and Terraform handles uploading it and configuring the function's runtime, memory, timeout, and environment variables.

## Remote State Backend

The `terraform-backend/` directory contains a separate Terraform project that creates the infrastructure for storing Terraform state remotely. This solves a fundamental problem: when multiple people or CI/CD pipelines run Terraform, they need to coordinate around a shared understanding of what exists. Local state files don't work for teams.

The backend uses an S3 bucket to store the state file itself. The bucket is configured with versioning (so you can rollback if something breaks), encryption at rest (state files contain sensitive resource IDs), and public access blocks (state should never be exposed). A DynamoDB table provides state locking—when someone runs `terraform apply`, they acquire a lock in this table, preventing anyone else from modifying state simultaneously. This prevents race conditions that could corrupt infrastructure.

## How Everything Connects

When you run Terraform commands in the main project, the tool first connects to the S3 backend to fetch the current state. It attempts to acquire a lock in DynamoDB—if someone else has the lock, your operation waits or fails depending on timeout settings. Once Terraform has the lock and state, it calls AWS APIs to check what actually exists in your account.

The Lambda function runs with the IAM role's permissions. When invoked, it writes structured logs to CloudWatch. The IAM policy scoped to that specific log group means the Lambda can't write to other log groups—even if compromised, the blast radius is limited. The log group's 7-day retention means old logs automatically expire, keeping storage costs predictable.

## Design Decisions

Creating the log group explicitly rather than relying on AWS defaults is intentional. Lambda will auto-create log groups if they don't exist, but those auto-created groups have no retention policy and use default settings. By creating the group in Terraform, we control its lifecycle, ensure consistent tagging, and can scope IAM permissions to exactly this resource. It's a small detail that reflects production thinking—don't let infrastructure "just happen," define it deliberately.

The IAM policy follows least privilege strictly. The first statement allows `CreateLogGroup` with a wildcard resource because the Lambda runtime might attempt this defensively, and it's a low-risk operation. The second statement restricts `CreateLogStream` and `PutLogEvents` to only the specific log group we created. This means even if the Lambda code is compromised, it can't inject logs into other applications' log groups or hide malicious activity elsewhere.

Remote state with locking isn't strictly necessary for a single-person project, but it demonstrates understanding of team workflows. In real production environments, multiple engineers and automated pipelines need to coordinate Terraform operations. The S3 + DynamoDB pattern is the industry-standard solution.

## Cost Implications

This architecture is designed to cost almost nothing at personal project scale. Lambda pricing is pay-per-request with a generous free tier. CloudWatch log ingestion and storage for 7 days of retention costs pennies unless you're generating massive log volumes. The S3 bucket and DynamoDB table use on-demand pricing—you only pay when Terraform operations occur, and for a personal project that's typically a few cents per month.

The infrastructure can be destroyed completely with `terraform destroy`, leaving no lingering resources to generate surprise bills. This is one of the key advantages of Infrastructure as Code—clean, complete teardown is as simple as clean, complete creation.

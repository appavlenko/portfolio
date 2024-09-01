# AWS Infrastructure with Terraform

This project demonstrates how to deploy and manage AWS infrastructure using Terraform. The infrastructure includes a Virtual Private Cloud (VPC), EC2 instances, S3 buckets, and additional AWS services for a more robust and secure setup. The Terraform configurations are modularized to allow easy scaling and reuse for different environments.

## Project Overview

The goal of this project is to provide a reusable Terraform configuration that can be used to quickly set up a foundational AWS infrastructure. This setup serves as a base for more complex deployments, learning Terraform, and understanding AWS infrastructure management. The configuration includes best practices for security, high availability, and monitoring.

## Files

- **main.tf**: The main Terraform file that references the modules for VPC, EC2, and S3.
- **variables.tf**: Defines the variables used in the Terraform configurations, allowing for flexibility and customization.
- **outputs.tf**: Defines the outputs that are returned after Terraform has run, including resource IDs and IP addresses.
- **provider.tf**: Configures the AWS provider, including AMI data sources for EC2 instances.

## Modules

- **vpc/**: Contains configurations for creating the VPC, subnets, route tables, and associated resources such as an Internet Gateway and NAT Gateway.
- **ec2/**: Contains configurations for deploying EC2 instances in both public and private subnets, with security groups and IAM roles.
- **s3/**: Contains configurations for creating S3 buckets, including logging and versioning for improved security and compliance.

## Additional Features

- **IAM Roles**: EC2 instances are configured with IAM roles for secure access to AWS services, avoiding the use of hardcoded credentials.
- **NAT Gateway**: Added for secure internet access from private subnets.
- **Load Balancer**: An optional module for deploying an Elastic Load Balancer (ELB) to distribute traffic across EC2 instances.
- **CloudWatch Monitoring**: Basic monitoring and logging setup for EC2 instances using CloudWatch.

## Prerequisites

- Terraform installed on your local machine.
- AWS CLI configured with appropriate credentials.
- An SSH key pair for accessing EC2 instances (if required).

## Usage

1. **Export AWS Credentials**:
   Ensure your AWS credentials are securely stored as environment variables:
   ```bash
   export AWS_ACCESS_KEY_ID="your-access-key"
   export AWS_SECRET_ACCESS_KEY="your-secret-key"

2. **Review the plan**:
   ```bash
   terraform plan
3. **Apply the configurations**:
   ```bash
   terraform apply
4. **Check the outputs**:
   ```bash
   terraform output

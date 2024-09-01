# AWS Infrastructure with Terraform

This project demonstrates how to deploy and manage AWS infrastructure using Terraform. The infrastructure includes a Virtual Private Cloud (VPC), EC2 instances, and S3 buckets. The Terraform configurations are modularized to allow easy scaling and reuse for different environments.

## Project Overview

The goal of this project is to provide a reusable Terraform configuration that can be used to quickly set up a basic AWS infrastructure. This setup can serve as a foundation for more complex deployments or as a learning tool for understanding Terraform and AWS infrastructure.

## Files

- **main.tf**: The main Terraform file that references the modules for VPC, EC2, and S3.
- **variables.tf**: Defines the variables used in the Terraform configurations.
- **outputs.tf**: Defines the outputs that are returned after Terraform has run.
- **provider.tf**: Configures the AWS provider.

## Modules

- **vpc/**: Contains configurations for creating the VPC, subnets, and route tables.
- **ec2/**: Contains configurations for deploying EC2 instances.
- **s3/**: Contains configurations for creating S3 buckets.

## Prerequisites

- Terraform installed on your local machine.
- AWS CLI configured with appropriate credentials.

## Usage

1. **Initialize the project**:
   ```bash
   terraform init
2. **Review the plan**:
   ```bash
   terraform plan
3. **Apply the configurations**:
   ```bash
   terraform apply
4. **Check the outputs**:
   ```bash
   terraform output

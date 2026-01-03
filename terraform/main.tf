provider "aws" {
  region = "us-east-1"
}

module "vpc" {
  source = "../../modules/vpc"

  vpc_name = "dev-vpc"
  cidr     = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]
}

module "eks" {
  source = "../../modules/eks"

  cluster_name    = "dev-eks"
  vpc_id          = module.vpc.vpc_id
  private_subnets = module.vpc.private_subnets
}
module "ecr" {
  source = "../../modules/ecr"

  repositories = [
    "user-service",
    "order-service",
    "payment-service",
    "inventory-service",
    "notification-service",
    "gateway-service"
  ]
}
name: Terraform EC2 Deployment

on:
  push:
    branches:
      - main

jobs:
  terraform:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v3

      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: ${{ secrets.AWS_REGION }}


      - name: Terraform Init
        run: terraform init
        working-directory: ec2-creation-in-us-east-1

      - name: Terraform Plan
        run: terraform plan
        working-directory: ec2-creation-in-us-east-1

      - name: Terraform Apply
        run: terraform apply -auto-approve
        working-directory: ec2-creation-in-us-east-1

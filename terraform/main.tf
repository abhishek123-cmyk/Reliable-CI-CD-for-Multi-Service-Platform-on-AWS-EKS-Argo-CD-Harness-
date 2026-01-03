provider "aws" {
  region = "us-east-1"
}

module "vpc" {
  source = "../Terraform/modules/vpc"


  vpc_name = "dev-vpc"
  cidr     = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]
}

module "eks" {
  source = "../Terraform/modules/eks"
}

  cluster_name    = "dev-eks"
  vpc_id          = module.vpc.vpc_id
  private_subnets = module.vpc.private_subnets
}

module "ecr" {
  source = "../Terraform/modules/ecr"
}

  repositories = [
    "user-service",
    "order-service",
    "payment-service",
    "inventory-service",
    "inventory-service",
    "notification-service",
    "gateway-service"
  ]
}


provider "aws" {
  profile = var.profile
  region  = var.region
}

# vpc module
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.10.0"

  name = "${var.project}-${var.env}"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b"]
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway = true
  enable_vpn_gateway = true
}

# ecr repository
resource "aws_ecr_repository" "ecr" {
  name = "${var.project}-${var.repo_name}-${var.env}"

  image_scanning_configuration {
    scan_on_push = true
  }
}

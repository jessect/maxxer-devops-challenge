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

# create ecr repository
resource "aws_ecr_repository" "ecr" {
  name = "${var.project}-${var.repo_name}-${var.env}"

  image_scanning_configuration {
    scan_on_push = true
  }
}

# create iam user for myapp get credentials from secretsmanager
resource "aws_iam_user" "myapp" {
  name = "myapp-iam"
}

resource "aws_iam_access_key" "myapp_key" {
  user = aws_iam_user.myapp.name
}

resource "aws_iam_user_policy" "myapp_policy" {
  name = "myapp-iam"
  user = aws_iam_user.myapp.name

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "myapp",
            "Effect": "Allow",
            "Action": [
                "secretsmanager:GetResourcePolicy",
                "secretsmanager:GetSecretValue",
                "secretsmanager:DescribeSecret",
                "secretsmanager:ListSecretVersionIds"
            ],
            "Resource": "${aws_secretsmanager_secret.app_credentials.arn}"
        }
    ]
}
EOF
}

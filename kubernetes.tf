provider "kubernetes" {
  host                   = data.aws_eks_cluster.eks.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.eks.token
}

data "aws_eks_cluster" "eks" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "eks" {
  name = module.eks.cluster_id
}

data "aws_caller_identity" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
}

# eks module
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "17.22.0"

  cluster_version = "1.21"
  cluster_name    = "${var.project}-${var.env}"
  vpc_id          = module.vpc.vpc_id
  subnets         = ["${element(module.vpc.private_subnets, 0)}", "${element(module.vpc.private_subnets, 1)}"]

  worker_groups = [
    {
      instance_type = "t3.large"
      asg_min_size  = 2
      asg_max_size  = 5
    }
  ]
  map_roles = [
    {
      rolearn  = "arn:aws:iam::${local.account_id}:role/${var.project}-codebuild-role"
      username = "${var.project}-codebuild-role"
      groups   = ["system:masters"]
    },
  ]

}

resource "null_resource" "kubeconfig" {
  provisioner "local-exec" {
    command = "aws eks --region ${var.region} update-kubeconfig --name ${var.project}-${var.env} --profile ${var.profile}"
  }
  depends_on = [module.eks.kubeconfig]
}

resource "kubernetes_namespace" "ns_project" {
  metadata {
    annotations = {
      name = var.project
    }

    name = var.project
  }
}

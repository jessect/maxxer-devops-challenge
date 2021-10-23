# codecommit repository
resource "aws_codecommit_repository" "repo" {
  repository_name = "${var.project}-${var.repo_name}"
  description     = "${var.repo_name} repository"
  default_branch  = var.repo_default_branch
}

# s3 bucket to store artifacts
resource "aws_s3_bucket" "build_artifact_bucket" {
  bucket        = "${var.project}-${var.repo_name}-artifacts"
  acl           = "private"
  force_destroy = var.force_artifact_destroy
}

# encryption key for build artifacts
resource "aws_kms_key" "artifact_encryption_key" {
  description             = "artifact-encryption-key"
  deletion_window_in_days = 10
}

# pipeline permissions
data "template_file" "codepipeline_policy_template" {
  template = file("${path.module}/templates/codepipeline.tpl")
  vars = {
    aws_kms_key     = aws_kms_key.artifact_encryption_key.arn
    artifact_bucket = aws_s3_bucket.build_artifact_bucket.arn
  }
}

data "template_file" "codepipeline_assume_role_policy_template" {
  template = file("${path.module}/templates/codebuild_assume_role.tpl")
}

data "template_file" "codebuild_policy_template" {
  template = file("${path.module}/templates/codebuild.tpl")
  vars = {
    artifact_bucket           = aws_s3_bucket.build_artifact_bucket.arn
    aws_kms_key               = aws_kms_key.artifact_encryption_key.arn
    codebuild_project_publish = aws_codebuild_project.publish_project.id
    codebuild_project_deploy  = aws_codebuild_project.deploy_project.id
  }
}

data "aws_iam_policy_document" "codepipeline_assume_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["codepipeline.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy" "attach_codepipeline_policy" {
  name = "${var.project}-codepipeline-policy"
  role = aws_iam_role.codepipeline_role.id

  policy = data.template_file.codepipeline_policy_template.rendered

}

resource "aws_iam_role" "codepipeline_role" {
  name               = "${var.project}-codepipeline-role"
  assume_role_policy = data.aws_iam_policy_document.codepipeline_assume_policy.json
}

resource "aws_iam_role" "codebuild_assume_role" {
  name               = "${var.project}-codebuild-role"
  assume_role_policy = data.template_file.codepipeline_assume_role_policy_template.rendered
}

resource "aws_iam_role_policy" "codebuild_policy" {
  name   = "${var.project}-codebuild-policy"
  role   = aws_iam_role.codebuild_assume_role.id
  policy = data.template_file.codebuild_policy_template.rendered
}

# buildspec templates
data "template_file" "buildspec_publish" {
  template = file("${path.module}/templates/buildspec_publish.yml.tpl")
}

data "template_file" "buildspec_deploy" {
  template = file("${path.module}/templates/buildspec_deploy.yml.tpl")
}


# codebuild section for the publish stage
resource "aws_codebuild_project" "publish_project" {
  name           = "${var.project}-${var.repo_name}-publish"
  description    = "The CodeBuild project for ${var.repo_name}"
  service_role   = aws_iam_role.codebuild_assume_role.arn
  build_timeout  = var.build_timeout
  encryption_key = aws_kms_key.artifact_encryption_key.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type    = var.build_compute_type
    image           = var.build_image
    type            = "LINUX_CONTAINER"
    privileged_mode = true

    environment_variable {
      name  = "IMAGE_REPO_NAME"
      value = "${var.project}-${var.repo_name}-${var.env}"
    }

    environment_variable {
      name  = "ECR_REPOSITORY"
      value = aws_ecr_repository.ecr.repository_url
    }

    environment_variable {
      name  = "AWS_ACCOUNT_ID"
      value = aws_ecr_repository.ecr.registry_id
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = data.template_file.buildspec_publish.rendered
  }
}

# codebuild section for the deploy stage
resource "aws_codebuild_project" "deploy_project" {
  name           = "${var.project}-${var.repo_name}-deploy"
  description    = "The CodeBuild project for ${var.repo_name}"
  service_role   = aws_iam_role.codebuild_assume_role.arn
  build_timeout  = var.build_timeout
  encryption_key = aws_kms_key.artifact_encryption_key.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type    = var.build_compute_type
    image           = var.build_image
    type            = "LINUX_CONTAINER"
    privileged_mode = true

    environment_variable {
      name  = "DB_HOST"
      value = module.rds.db_instance_address
    }

    environment_variable {
      name  = "DB_NAME"
      value = var.project
    }

    environment_variable {
      name  = "DB_USER"
      value = var.app_user
    }

    environment_variable {
      name  = "DB_PASS"
      value = random_password.app_password.result
    }

    environment_variable {
      name  = "K8S_CLUSTER_NAME"
      value = "${var.project}-${var.env}"
    }

    environment_variable {
      name  = "K8S_NAMESPACE"
      value = var.project
    }

    environment_variable {
      name  = "IMAGE_REPO_NAME"
      value = "${var.project}-${var.repo_name}-${var.env}"
    }

    environment_variable {
      name  = "ECR_REPOSITORY"
      value = aws_ecr_repository.ecr.repository_url
    }

    environment_variable {
      name  = "AWS_ACCOUNT_ID"
      value = aws_ecr_repository.ecr.registry_id
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = data.template_file.buildspec_deploy.rendered
  }
}

# pipeline with 3 stages (source, publish and deploy)
resource "aws_codepipeline" "pipeline" {
  name     = "${var.project}-${var.repo_name}-${var.repo_default_branch}"
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    location = aws_s3_bucket.build_artifact_bucket.bucket
    type     = "S3"

    encryption_key {
      id   = aws_kms_key.artifact_encryption_key.arn
      type = "KMS"
    }
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeCommit"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        RepositoryName = "${var.project}-${var.repo_name}"
        BranchName     = var.repo_default_branch
      }
    }
  }

  stage {
    name = "Publish"

    action {
      name            = "Publish"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      input_artifacts = ["source_output"]
      version         = "1"

      configuration = {
        ProjectName = aws_codebuild_project.publish_project.name
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name            = "Deploy"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      input_artifacts = ["source_output"]
      version         = "1"

      configuration = {
        ProjectName = aws_codebuild_project.deploy_project.name
      }
    }
  }
}

# push the source dir to codecommit repository
resource "null_resource" "codecommit_push" {
  provisioner "local-exec" {
    command     = <<EOT
    pip install git-remote-codecommit
    git init
    git add .
    git commit -m 'Initial commit'
    git push --set-upstream codecommit::us-east-1://${var.project}-${var.repo_name} ${var.repo_default_branch}
    rm .git -rf
    EOT
    working_dir = "./source"
  }

  depends_on = [aws_codepipeline.pipeline]

}

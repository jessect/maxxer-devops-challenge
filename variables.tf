variable "profile" {
  description = "Profile configured on ~/.aws/credentials"
  default     = "default"
}

variable "region" {
  description = "Region name"
  default     = "us-east-1"
}

variable "project" {
  description = "Project name"
  default     = "jaylabs"
}

variable "env" {
  description = "Environment name"
  default     = "dev"
}

variable "app_user" {
  description = "User account for database"
  default     = "appuser"
}

variable "repo_name" {
  description = "Cdecommit repository"
  default     = "myapp"
}

variable "repo_default_branch" {
  description = "Default repository branch"
  default     = "develop"
}

variable "force_artifact_destroy" {
  description = "Force S3 bucket on destroy"
  default     = "true"
}

variable "build_timeout" {
  description = "CodeBuild timeout (minutes)"
  default     = "5"
}

variable "build_compute_type" {
  description = "Instance type for CodeBuild"
  default     = "BUILD_GENERAL1_SMALL"
}

variable "build_image" {
  description = "Image for CodeBuild to use"
  default     = "aws/codebuild/amazonlinux2-x86_64-standard:3.0"
}

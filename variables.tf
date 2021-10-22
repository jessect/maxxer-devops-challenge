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
  description = "Name of the codecommit repository"
  default     = "myapp"
}

variable "repo_default_branch" {
  description = "The name of the default repository branch"
  default     = "develop"
}

variable "force_artifact_destroy" {
  description = "Force the removal of the artifact S3 bucket on destroy"
  default     = "true"
}

variable "build_timeout" {
  description = "The time to wait for a CodeBuild to complete before timing out in minutes"
  default     = "5"
}

variable "build_compute_type" {
  description = "The build instance type for CodeBuild"
  default     = "BUILD_GENERAL1_SMALL"
}

variable "build_image" {
  description = "The build image for CodeBuild to use"
  default     = "aws/codebuild/amazonlinux2-x86_64-standard:3.0"
}

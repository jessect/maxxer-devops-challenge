# Infrastructure Provisioning with Terraform

## Introduction

The objective of this project is to deploy with just one command a complete environment, including CI / CD pipeline and monitoring tools using infrastructure as code (IaC) .

## AWS Services

* Amazon Virtual Private Cloud (VPC)
* Amazon Elastic Kubernetes Service (EKS)
* Amazon Elastic Container Registry (ECR)
* Amazon Relational Database Service (RDS)
* Amazon S3
* AWS CodeCommit
* AWS CodeBuild
* AWS CodePipeline
* AWS Secrets Manager


## Requirements

- [terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli) v1.0.9
- [aws cli](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html) 2.3.0
- [kubectl](https://docs.aws.amazon.com/eks/latest/userguide/install-kubectl.html) 1.21
- [helm](https://helm.sh/docs/intro/install/) 3.7.1
- [git](https://github.com/git-guides/install-git) 2.31.1
- [git-remote-codecommit](https://docs.aws.amazon.com/codecommit/latest/userguide/setting-up-git-remote-codecommit.html#setting-up-git-remote-codecommit-install) 1.25.10

## AWS Credentials

Terraform requires that AWS CLI has administrative access for deployment.

* Generate [API access keys](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_access-keys.html#Using_CreateAccessKey).

* Create credentials file in the ~/.aws/ directory to configure AWS CLI.
```
$ aws configure
AWS Access Key ID [None]: AKIAIOSFODNN7EXAMPLE
AWS Secret Access Key [None]: wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
Default region name [None]: us-east-1
Default output format [None]: json
``` 

* Add account profiles to ~/.aws/credentials:

```
$ aws configure set region us-east-1 --profile default
```

## Terraform Overview

### Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 3.63.0 |
| <a name="provider_helm"></a> [helm](#provider\_helm) | 2.3.0 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | 2.6.0 |


### Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_eks"></a> [eks](#module\_eks) | terraform-aws-modules/eks/aws | 17.22.0 |
| <a name="module_rds"></a> [rds](#module\_rds) | terraform-aws-modules/rds/aws | 3.4.0 |
| <a name="module_sg"></a> [sg](#module\_sg) | terraform-aws-modules/security-group/aws | 4.4.0 |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | terraform-aws-modules/vpc/aws | 3.10.0 |


### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_user"></a> [app\_user](#input\_app\_user) | User account for database | `string` | `"appuser"` | no |
| <a name="input_build_compute_type"></a> [build\_compute\_type](#input\_build\_compute\_type) | The build instance type for CodeBuild | `string` | `"BUILD_GENERAL1_SMALL"` | no |
| <a name="input_build_image"></a> [build\_image](#input\_build\_image) | The build image for CodeBuild to use | `string` | `"aws/codebuild/amazonlinux2-x86_64-standard:3.0"` | no |
| <a name="input_build_timeout"></a> [build\_timeout](#input\_build\_timeout) | The time to wait for a CodeBuild to complete before timing out in minutes | `string` | `"5"` | no |
| <a name="input_env"></a> [env](#input\_env) | Environment name | `string` | `"dev"` | no |
| <a name="input_force_artifact_destroy"></a> [force\_artifact\_destroy](#input\_force\_artifact\_destroy) | Force the removal of the artifact S3 bucket on destroy | `string` | `"true"` | no |
| <a name="input_profile"></a> [profile](#input\_profile) | Profile configured on ~/.aws/credentials | `string` | `"default"` | no |
| <a name="input_project"></a> [project](#input\_project) | Project name | `string` | `"jaylabs"` | no |
| <a name="input_region"></a> [region](#input\_region) | Region name | `string` | `"us-east-1"` | no |
| <a name="input_repo_default_branch"></a> [repo\_default\_branch](#input\_repo\_default\_branch) | The name of the default repository branch | `string` | `"develop"` | no |
| <a name="input_repo_name"></a> [repo\_name](#input\_repo\_name) | Name of the codecommit repository | `string` | `"myapp"` | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_database_admin_user"></a> [database\_admin\_user](#output\_database\_admin\_user) | Show database username |
| <a name="output_database_host"></a> [database\_host](#output\_database\_host) | Show database address |
| <a name="output_database_master_password"></a> [database\_master\_password](#output\_database\_master\_password) | Show database master password |
| <a name="output_database_name"></a> [database\_name](#output\_database\_name) | Show database name |
| <a name="output_kubeconfig"></a> [kubeconfig](#output\_kubeconfig) | Create kubeconfig automatically |




## API Endpoints (myapp - golang-crud)

CRUD operation using Golang and MySql

### Get user
- Path : `/get`
- Method: `GET`

### Creater user
- Path : `/create`
- Method: `POST`

### Update user
- Path : `/update/{id}`
- Method: `PUT`

### Delete user
- Path : `/delete/{id}`
- Method: `DELETE`

## Terraform Overview

### Providers
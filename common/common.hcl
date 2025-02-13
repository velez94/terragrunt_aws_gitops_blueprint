# Load variables in locals
# Load variables in locals
locals {
  # Default values for variables
  project           = "gitops-scale"


   # Backend Configuration
  backend_profile       = "labvel-devsecops"
  backend_region        = "us-east-2"
  backend_bucket_name   = "labvel-artifacts-terraform-tfstate"
  backend_key           = "terraform.tfstate"
  backend_dynamodb_lock = "db-terraform-lock"
  backend_encrypt       = true
  project_folder = "${local.project}"

}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
variable "profile" {
  description = "Variable for credentials management."
  type        = map(map(string))
}

variable "env" {
  description = "Environment Value"
  type = string
  default = "default"
}

variable "project" {
  description = "Project name"
  type        = string
}

variable "required_tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
}

provider "aws" {
  region  = var.profile[var.env]["region"]
  profile = var.profile[var.env]["profile"]

  default_tags {
    tags = var.required_tags
  }
}
EOF
}

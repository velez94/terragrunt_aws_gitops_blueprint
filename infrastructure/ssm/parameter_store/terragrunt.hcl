#parameter_store-terragrunt.hcl

include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

dependency "eks" {
  config_path = "${get_parent_terragrunt_dir("root")}/infrastructure/containers/eks_control_plane"
  mock_outputs = {
    cluster_name                       = "dummy-cluster-name"
    cluster_endpoint                   = "dummy_cluster_endpoint"
    cluster_certificate_authority_data = "dummy_cluster_certificate_authority_data"
    cluster_version                    = "1.31"
    cluster_platform_version           = "1.31"
    oidc_provider_arn                  = "dummy_arn"
    cluster_arn                        = "arn:aws:eks:us-east-2:105171185823:cluster/gitops-scale-dev-hub"
  }
  mock_outputs_merge_strategy_with_state = "shallow"
}

locals {
  # Define parameters for each workspace
  env = {
    default = {

      parameter_name     = "/control_plane/${include.root.locals.environment.locals.workspace}/credentials"
      sharing_principals = ["ou-w3ow-k24p2opx"]
      tags = {
        Environment = "control-plane"
        Layer       = "Operations"
      }
    }
    "dev" = {

      create = true
    }
    "prod" = {

      create = true
    }
  }
  # Merge parameters
  environment_vars = contains(keys(local.env), include.root.locals.environment.locals.workspace) ? include.root.locals.environment.locals.workspace : "default"
  workspace        = merge(local.env["default"], local.env[local.environment_vars])
}


terraform {
  source = "../../../modules/terraform-aws-ssm-parameter-sotre"

}

inputs = {
  parameter_name        = "${local.workspace["parameter_name"]}"
  parameter_description = "Control plane credentials"
  parameter_type        = "SecureString"
  parameter_tier        = "Advanced"
  create_kms            = true
  enable_sharing        = true
  sharing_principals    = local.workspace["sharing_principals"]
  parameter_value = jsonencode({
    cluster_name                       = dependency.eks.outputs.cluster_name,
    cluster_endpoint                   = dependency.eks.outputs.cluster_endpoint,
    cluster_certificate_authority_data = dependency.eks.outputs.cluster_certificate_authority_data,
    cluster_version                    = dependency.eks.outputs.cluster_version,
    cluster_platform_version           = dependency.eks.outputs.cluster_platform_version,
    oidc_provider_arn                  = dependency.eks.outputs.oidc_provider_arn,
    hub_account_id                     = split(":", dependency.eks.outputs.cluster_arn)[4]
  })
  tags = local.workspace["tags"]

}
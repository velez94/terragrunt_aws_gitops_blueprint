#eks_role-terragrunt.hcl

include "root" {
  path = find_in_parent_folders("root.hcl")
  expose = true
}


dependency "eks" {
  config_path = "${get_parent_terragrunt_dir("root")}/infrastructure/containers/eks_control_plane"
  mock_outputs = {
    cluster_name = "dummy-cluster-name"
    cluster_endpoint = "dummy_cluster_endpoint"
    cluster_certificate_authority_data = "dummy_cluster_certificate_authority_data"
    cluster_version = "1.31"
    cluster_platform_version = "1.31"
    oidc_provider_arn =  "dummy_arn"
  }
  mock_outputs_merge_strategy_with_state = "shallow"
}
locals {
  # Define parameters for each workspace
  env = {
    default = {

      environment  = "control-plane"
      role_name    = "eks-role-hub"
      tags = {
        Environment = "control-plane"
        Layer       = "Networking"
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
  workspace = merge(local.env["default"], local.env[local.environment_vars])
}


terraform {
  source = "tfr:///terraform-aws-modules/iam/aws//modules/iam-eks-role?version=5.55.0"

}

inputs = {
   role_name = "${local.workspace["role_name"]}-${local.workspace["environment"]}"

  cluster_service_accounts = {
    "${dependency.eks.outputs.cluster_name}" = [
      "argocd:argocd-*",
    ]
  }
  tags = local.workspace["tags"]

}
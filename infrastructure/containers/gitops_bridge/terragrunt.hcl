#eks_control_plane-terragrunt.hcl
include "root" {
  path = find_in_parent_folders("root.hcl")
  expose = true
}

#include "kubectl_provider" {
#  path = find_in_parent_folders("/common/additional_providers/provider_kubectl.hcl")
#}

include "k8s_helm_provider" {
  path = find_in_parent_folders("/common/additional_providers/provider_k8s_helm.hcl")
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
      oss_addons = {
        enable_argo_workflows = true
        #enable_foo            = true
        # you can add any addon here, make sure to update the gitops repo with the corresponding application set
      }

      addons_metadata = merge(
        {
          addons_repo_url      = "https://github.com/gitops-bridge-dev/gitops-bridge-argocd-control-plane-template"
          addons_repo_basepath = ""
          addons_repo_path     ="bootstrap/control-plane/addons"
          addons_repo_revision = "HEAD"
        }
      )
      argocd_apps = {
        addons = file("./bootstrap/addons.yaml")
        #workloads = file("./bootstrap/workloads.yaml")
      }

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
  source = "tfr:///gitops-bridge-dev/gitops-bridge/helm?version=0.1.0"

}

inputs = {
  cluster_name                       = dependency.eks.outputs.cluster_name
  cluster_endpoint                   = dependency.eks.outputs.cluster_endpoint
  cluster_platform_version           = dependency.eks.outputs.cluster_platform_version
  oidc_provider_arn                  = dependency.eks.outputs.oidc_provider_arn
  cluster_certificate_authority_data = dependency.eks.outputs.cluster_certificate_authority_data

  cluster = {
    cluster_name =   dependency.eks.outputs.cluster_name
    environment  = local.workspace["environment"]
    metadata     = local.workspace["addons_metadata"]
    addons = merge(local.workspace["oss_addons"], { kubernetes_version = dependency.eks.outputs.cluster_version })

  }
  apps = local.workspace["argocd_apps"]

  tags = local.workspace["tags"]

}
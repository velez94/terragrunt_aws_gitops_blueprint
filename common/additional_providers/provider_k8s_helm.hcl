generate "k8s_helm_provider" {
  path      = "k8s_helm_provider.tf"
  if_exists = "overwrite"
  contents = <<EOF
################################################################################
# Kubernetes Access for Spoke Cluster
################################################################################
variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "cluster_endpoint" {
  description = "Endpoint for your Kubernetes API server"
  type        = string
}

variable "cluster_platform_version" {
  description = "Platform version for the cluster"
  type        = string
}

variable "oidc_provider_arn" {
  description = "The ARN of the OIDC Provider"
  type        = string
}

variable "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data required to communicate with the cluster"
  type        = string
}

provider "kubernetes" {
  host                   = var.cluster_endpoint
  cluster_ca_certificate = base64decode(var.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command = "aws"
    # This requires the awscli to be installed locally where Terraform is executed
    args        = [
      "eks", "get-token", "--cluster-name", var.cluster_name, "--region", data.aws_region.current.name, "--profile",
      var.profile[var.env]["profile"]

    ]
  }
}

provider "helm" {
  kubernetes {
    host                   = var.cluster_endpoint
    cluster_ca_certificate = base64decode(var.cluster_certificate_authority_data)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command = "aws"
      # This requires the awscli to be installed locally where Terraform is executed
      args        = [
        "eks", "get-token", "--cluster-name", var.cluster_name, "--region", data.aws_region.current.name, "--profile",
        var.profile[var.env]["profile"]
      ]
    }
  }
}

EOF
}

#TODO unificated providers
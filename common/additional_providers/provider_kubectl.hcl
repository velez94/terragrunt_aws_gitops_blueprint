generate "kubectl_provider" {
  path      = "kubectl_provider.tf"
  if_exists = "overwrite"
  contents = <<EOF
terraform {
  required_version = ">= 0.13"

  required_providers {
    kubectl = {
      source  = "alekc/kubectl"
      version = ">= 2.0.0"
    }
  }
}
provider "kubectl" {
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

EOF
}
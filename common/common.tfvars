
# Default values for deployment credentials
# Access profile in your IDE env or pipeline the IAM user to use for deployment."
profile = {
  default = {
    profile = "labvel-dev"
    region  = "us-east-2"
  }
  "dev" = {
    profile = "labvel-dev"
    region  = "us-east-2"
  }
}


# Project default tags
project = "gitops-scale"
required_tags = {
    ManagedBy = "Terragrunt"
    Initiative = "BlogsAmbassador"
    Project = "gitops-scale"

}

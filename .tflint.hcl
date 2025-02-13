
plugin "aws" {
    enabled = true
    version = "0.21.1"
    source  = "github.com/terraform-linters/tflint-ruleset-aws"
}
config {
  module = true
}

plugin "terraform" {
    enabled = true
    version = "0.2.2"
    source  = "github.com/terraform-linters/tflint-ruleset-terraform"
}

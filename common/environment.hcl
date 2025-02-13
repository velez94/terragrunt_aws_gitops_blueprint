locals {
  workspace = get_env("TF_VAR_env", "dev")
  pipeline = "false"
}
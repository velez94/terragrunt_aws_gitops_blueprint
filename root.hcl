locals {
  common_vars = read_terragrunt_config("${get_parent_terragrunt_dir()}/common/common.hcl")
   environment = read_terragrunt_config("${get_parent_terragrunt_dir()}/common/environment.hcl")
}

inputs = {
  COMMAND        = get_terraform_cli_args()
  COMMAND_GLOBAL = local.common_vars.locals
}

terraform {
  extra_arguments "init_arg" {
    commands  = ["init"]
    arguments = [
      "-reconfigure"
    ]
    env_vars = {
      TERRAGRUNT_AUTO_INIT = true

    }
  }

  extra_arguments "common_vars" {
    commands = get_terraform_commands_that_need_vars()

    arguments = [
      "-var-file=${get_parent_terragrunt_dir()}/common/common.tfvars"

    ]
  }
/*
  after_hook "sync_workspace" {
    commands = ["workspace"]
    execute  = [
      "thothctl", "--sync_terraform_workspaces",

    ]

  }

  before_hook "sync_workspaces" {
    commands = ["plan", "apply", "destroy", "refresh", "state"]
    execute  = [
      "thothctl", "--sync_terraform_workspaces",

    ]

  }
*/

}


remote_state {
  backend = "s3"
  generate = {
    path      = "remotebackend.tf"
    if_exists = "overwrite"
  }
 config = {
    profile        = "false" == local.environment.locals.pipeline ? local.common_vars.locals.backend_profile : "backend_profile"
    region         = local.common_vars.locals.backend_region
    bucket         = local.common_vars.locals.backend_bucket_name
    key            = "${local.common_vars.locals.project_folder}/${local.environment.locals.workspace}/${path_relative_to_include()}/${local.common_vars.locals.backend_key}"
    dynamodb_table = local.common_vars.locals.backend_dynamodb_lock
    encrypt        = local.common_vars.locals.backend_encrypt


    }
}

generate = local.common_vars.generate



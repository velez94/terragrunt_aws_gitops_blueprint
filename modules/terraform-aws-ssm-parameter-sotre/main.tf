/*
* # Module for terraform-aws-ssm-parameter-sotre deployment
*
* Terraform stack to provision a custom terraform-aws-ssm-parameter-sotre
*
*/
locals {
  kms_id = var.kms_key_id == null && var.create_kms ? module.kms.key_id : var.kms_key_id
}
# module CMK
module "kms" {
  create                  = var.create_kms
  source                  = "terraform-aws-modules/kms/aws"
  version                 = "3.1.1"
  aliases = ["alias/${var.parameter_name}"]
  deletion_window_in_days = var.kms_deletion_window_in_days
  description             = "CMK for shared parameter ${var.parameter_name}"
  policy                  = data.aws_iam_policy_document.kms_policy.json
  tags                    = var.tags

}
resource "aws_ssm_parameter" "parameter" {
  count = var.enable ? 1 : 0

  name        = var.parameter_name
  description = var.parameter_description
  value       = var.parameter_value
  type        = var.parameter_type
  tier        = var.parameter_tier
  overwrite   = var.overwrite

  key_id = var.parameter_type == "SecureString" ? local.kms_id : null

  tags = merge(
    var.tags,
    {
      "Managed-By" = "Terraform"
    }
  )

  lifecycle {
    precondition {
      condition     = var.parameter_type == "SecureString" && var.parameter_tier == "Advanced" ? local.kms_id != null : true
      error_message = "KMS key ID is required for SecureString parameters when using Advanced tier"
    }
  }
}


resource "aws_ram_resource_share" "parameter_share" {
  count                     = var.enable_sharing ? 1 : 0
  name = coalesce(var.resource_share_name, "${replace(aws_ssm_parameter.parameter[0].name, "/", "-")}-ssm-parameter-share")
  allow_external_principals = var.allow_external_principals

  lifecycle {
    precondition {
      condition     = var.enable_sharing == true
      error_message = "Parameter sharing must be explicitly enabled via enable_sharing variable"
    }
  }

  tags = var.tags
}
resource "aws_ram_resource_association" "parameter_association" {
  count              = var.enable_sharing ? 1 : 0
  resource_arn       = aws_ssm_parameter.parameter[0].arn
  resource_share_arn = aws_ram_resource_share.parameter_share[0].arn

  lifecycle {
    precondition {
      condition     = length(var.sharing_principals) > 0 || length(var.sharing_ou_ids) > 0
      error_message = "At least one sharing principal must be specified when sharing is enabled"
    }
  }
}

resource "aws_ram_principal_association" "parameter_principal_association" {
  for_each           = var.enable_sharing ? toset(var.sharing_principals) : []
  principal          = each.value
  resource_share_arn = aws_ram_resource_share.parameter_share[0].arn

  lifecycle {
    precondition {
      condition = (
      can(regex("^\\d{12}$", each.value)) || # AWS account ID
      can(regex("^arn:aws:organizations::\\d{12}:organization/o-[a-z0-9]{10,32}$", each.value)) || # Organization ARN
      can(regex("^arn:aws:organizations::\\d{12}:ou/o-[a-z0-9]{10,32}/ou-[a-z0-9]{4,32}-[a-z0-9]{8,32}$", each.value)) # OU ARN
      )
      error_message = "Invalid principal format. Must be either a 12-digit AWS account ID, Organization ARN, or Organizational Unit ARN"
    }
  }
}

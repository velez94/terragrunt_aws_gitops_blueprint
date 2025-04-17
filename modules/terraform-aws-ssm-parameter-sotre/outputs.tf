output "parameter_arn" {
  description = "The ARN of the parameter"
  value       = try(aws_ssm_parameter.parameter[0].arn, "")
}

output "parameter_name" {
  description = "The name of the parameter"
  value       = try(aws_ssm_parameter.parameter[0].name, "")
}

output "parameter_version" {
  description = "The version of the parameter"
  value       = try(aws_ssm_parameter.parameter[0].version, "")
}

output "parameter_type" {
  description = "The type of the parameter"
  value       = try(aws_ssm_parameter.parameter[0].type, "")
}

output "parameter_tier" {
  description = "The tier of the parameter"
  value       = try(aws_ssm_parameter.parameter[0].tier, "")
}

output "is_enabled" {
  description = "Whether the parameter store is enabled"
  value       = var.enable
}


output "parameter_share_arn" {
  description = "ARN of the RAM resource share"
  value       = var.enable_sharing ? aws_ram_resource_share.parameter_share[0].arn : null
}

output "parameter_share_id" {
  description = "ID of the RAM resource share"
  value       = var.enable_sharing ? aws_ram_resource_share.parameter_share[0].id : null
}


output "resource_association_id" {
  description = "ID of the RAM resource association"
  value       = var.enable_sharing ? aws_ram_resource_association.parameter_association[0].id : null
}

output "principal_associations" {
  description = "Map of principal associations and their details"
  value = var.enable_sharing ? {
    for k, v in aws_ram_principal_association.parameter_principal_association : k => {
      id            = v.id
      principal     = v.principal
      association_type = "PRINCIPAL"
    }
  } : {}
}

output "shared_parameter_arn" {
  description = "ARN of the shared SSM parameter"
  value       = var.enable_sharing ?  aws_ssm_parameter.parameter[0].arn : null
}


output "sharing_status" {
  description = "Overall sharing status and configuration"
  value = {
    enabled                   = var.enable_sharing
    allow_external_principals = var.enable_sharing ? var.allow_external_principals : null
    number_of_principals      = var.enable_sharing ? length(var.sharing_principals) : 0
    tier                      = aws_ssm_parameter.parameter[0].tier
  }
}

variable "enable" {
  description = "Controls if the Parameter Store should be created"
  type        = bool
  default     = true
}

variable "parameter_name" {
  description = "The name of the parameter"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9_.-/]+$", var.parameter_name))
    error_message = "Parameter name can only contain alphanumeric characters, periods, hyphens, underscores, and forward slashes."
  }
}

variable "parameter_description" {
  description = "Description of the parameter"
  type        = string
  default     = null
}

variable "parameter_value" {
  description = "Value of the parameter"
  type        = string
  sensitive   = true
}

variable "parameter_type" {
  description = "Type of the parameter. Valid values: String, StringList, SecureString"
  type        = string
  default     = "SecureString"

  validation {
    condition     = contains(["String", "StringList", "SecureString"], var.parameter_type)
    error_message = "Parameter type must be one of: String, StringList, SecureString"
  }
}

variable "parameter_tier" {
  description = "Tier of the parameter. Valid values: Standard, Advanced, Intelligent-Tiering"
  type        = string
  default     = "Standard"

  validation {
    condition     = contains(["Standard", "Advanced", "Intelligent-Tiering"], var.parameter_tier)
    error_message = "Parameter tier must be one of: Standard, Advanced, Intelligent-Tiering"
  }
}

variable "kms_key_id" {
  description = "KMS key ID or ARN for encrypting SecureString parameters"
  type        = string
  default     = null
}
variable "create_kms" {
  description = "Controls if the KMS key should be created"
  type        = bool
  default     = true
}

variable "kms_deletion_window_in_days" {
  default = 7
  description = "Duration in days after which the key is deleted after destruction of the resource"
  type        = number
}
variable "tags" {
  description = "Tags to apply to the parameter"
  type        = map(string)
  default     = {}
}

variable "overwrite" {
  description = "Overwrite an existing parameter"
  type        = bool
  default     = true
}
##################################################################################
# SSM Parameter Sharing using RAM
##################################################################################
variable "enable_sharing" {
  description = "Enable parameter sharing using AWS RAM"
  type        = bool
  default     = false
}

variable "sharing_principals" {
  description = "List of principals to share the parameter with (AWS account IDs, Organization ARNs, or OU ARNs)"
  type        = list(string)
  default     = []
}

variable "resource_share_name" {
  description = "Name of the resource share"
  type        = string
  default     = null
}

variable "allow_external_principals" {
  description = "Indicates whether principals outside your organization can be associated with a resource share"
  type        = bool
  default     = false
}



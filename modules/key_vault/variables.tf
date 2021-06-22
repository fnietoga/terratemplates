####REQUIRED Input Variables
variable "resource_group_name" {
  type        = string
  description = "(Required) The name of the resource group in which to create the Resource. Changing this forces a new resource to be created."
}
variable "kv_name" {
  type        = string
  description = " (Required) Specifies the name of the Key Vault. Changing this forces a new resource to be created."
  validation {
    condition = can(regex("^[a-zA-Z]{1}[a-zA-Z0-9-]{2,23}$",var.kv_name))
    error_message = "Vault name must only contain alphanumeric characters and dashes and cannot start with a number, and must be between 3 and 24 alphanumeric characters."
  }
}

####OPTIONAL Input Variables
variable "azure_location" {
  type        = string
  description = "(Optional) Specifies the supported Azure location where the resource exists. Changing this forces a new resource to be created. Defaults to westeurope."
  default     = "westeurope"
  validation {
    condition     = contains(["westeurope", "northeurope"], var.azure_location)
    error_message = "The location specified must be one of the allowed values (westeurope, northeurope)."
  }
}

variable "tags" {
  type = map
  description = "(Optional) A mapping of tags which should be assigned to the resource."
  default= {}
} 

variable "kv_sku_name" {
  type        = string
  description = "(Optional) The Name of the SKU used for this Key Vault. Possible values are standard and premium. Defaults to standard."
  default     = "standard"
  validation {
    condition     = contains(["standard", "premium"], var.kv_sku_name)
    error_message = "The Name of the SKU specified must be one of the allowed values (standard, premium)."
  }
}

variable "kv_enabled_for_deployment" {
  type        = bool
  description = "(Optional) Boolean flag to specify whether Azure Virtual Machines are permitted to retrieve certificates stored as secrets from the key vault. Defaults to false."
  default     = false
}

variable "kv_enabled_for_disk_encryption" {
  type        = bool
  description = "(Optional) Boolean flag to specify whether Azure Disk Encryption is permitted to retrieve secrets from the vault and unwrap keys. Defaults to false."
  default     = false
}

variable "kv_enabled_for_template_deployment" {
  type        = bool
  description = "(Optional) Boolean flag to specify whether Azure Resource Manager is permitted to retrieve secrets from the key vault. Defaults to false."
  default     = false
}

variable "kv_enable_rbac_authorization" {
  type        = bool
  description = "(Optional) Boolean flag to specify whether Azure Key Vault uses Role Based Access Control (RBAC) for authorization of data actions. Defaults to false."
  default     = false
}

variable "kv_purge_protection_enabled" {
  type        = bool
  description = "(Optional) Is Purge Protection enabled for this Key Vault? Defaults to false."
  default     = false
}

variable "kv_soft_delete_retention_days" {
  type        = number
  description = "(Optional) The number of days that items should be retained for once soft-deleted. This value can be between 7 and 90 (the default) days"
  default     = 90
  validation {
    condition     = (
      var.kv_soft_delete_retention_days >= 7 &&
      var.kv_soft_delete_retention_days <= 90
    )
    error_message = "The number of days of retention must be between 7 and 90 days."
  }
}

variable "kv_access_policies" {
  type = list(object({
    object_id               = string
    certificate_permissions = optional(list(string))
    key_permissions         = optional(list(string))
    secret_permissions      = optional(list(string))
    storage_permissions     = optional(list(string))
  }))
  description = "Object collection with information for additional access policies access to be applied to the Deployment Key Vault."
  default = []
}

# Local variables used to reduce repetition 
locals {
  kv_deploy_ips = [
    "${chomp(data.http.myip.body)}/32" != "" ? "${chomp(data.http.myip.body)}/32" : null
  ]
}

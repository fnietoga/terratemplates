####REQUIRED Input Variables
variable "resource_group_name" {
  type        = string
  description = "(Required) The name of the resource group in which to create the Resource. Changing this forces a new resource to be created."
}

variable "app_name" {
  type        = string
  description = "Project or Application name, added to all resource names as a prefix."
  validation {
    condition = (
      length(var.app_name) >= 2 &&
      length(var.app_name) <= 10 &&
      can(regex("^[a-zA-Z0-9]+$", var.app_name))
    )
    error_message = "(Required) The application name must be between 2 to 10 characters, only letters and numbers are allowed."
  }
}

variable "environment" {
  type        = string
  description = "environment short name"
  default     = "dev"
  validation {
    condition     = contains(["dev", "pre", "pro"], var.environment)
    error_message = "(Required) The environment specified must be one of the allowed values (dev, pre, pro)."
  }
}

####OPTIONAL Input Variables
variable "instance_name" {
  type        = string
  description = "(Optional) part of the name to identify this instance of the resource service from other existing ones."
  validation {
    condition = (
      length(var.instance_name) == 0 || (
        length(var.instance_name) >= 2 &&
        length(var.instance_name) <= 6 &&
        can(regex("^[a-zA-Z0-9]+$", var.instance_name))
      )
    )
    error_message = "(Required) The instance name must be between 2 to 6 characters, only letters and numbers are allowed."
  }
  default = ""
}

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
  type        = map(any)
  description = "(Optional) A mapping of tags which should be assigned to the resource."
  default     = {}
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
    condition = (
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
  default     = []
}

variable "kv_allowed_ips" {
  type        = list(string)
  description = "(Optional) List of IP Addresses to allow through the Key Vault firewall."
  default     = []
}

variable "apply_global_config" {
  type        = bool
  description = "(Optional) Specify if the global configuration must be applied."
  default     = true
}

#Deployment current public IP
data "http" "myip" {
  url = "http://ipv4.icanhazip.com"
}

## Read global config from key vault
data "azurerm_key_vault" "config" {
  count = var.apply_global_config == true ? 1 : 0

  name                = "KVT-IAC-${upper(var.environment)}"
  resource_group_name = var.environment == "pro" ? "RG-IAC" : "RG-IAC-${upper(var.environment)}"
}
data "azurerm_key_vault_secret" "fw-allowed-ips" {
  count = var.apply_global_config == true ? 1 : 0

  name         = "fw-allowed-ips"
  key_vault_id = data.azurerm_key_vault.config[0].id
}

# Local variables used to reduce repetition 
locals {
  kv_name = var.instance_name != "" ? "KVT-${upper(var.app_name)}-${upper(var.instance_name)}-${upper(var.environment)}" : "KVT-${upper(var.app_name)}-${upper(var.environment)}"
  kv_fw_ips = distinct(concat(
    var.kv_allowed_ips,
    var.apply_global_config == true ? jsondecode(nonsensitive(data.azurerm_key_vault_secret.fw-allowed-ips[0].value)) : [],
    [chomp(data.http.myip.body) != "" ? chomp(data.http.myip.body) : null]
  ))
  kv_access_policies = concat(var.kv_access_policies, [{
    object_id               = data.azurerm_client_config.current.object_id
    certificate_permissions = ["get", "list", "create", "update", "delete", "purge", "recover"]
    key_permissions         = ["get", "list", "create", "update", "verify", "delete", "purge"]
    secret_permissions      = ["get", "list", "set", "delete", "purge", "recover", "backup", "restore"]
    storage_permissions     = ["get", "list", "set", "update", "regeneratekey", "delete", "purge"]
  }])
}

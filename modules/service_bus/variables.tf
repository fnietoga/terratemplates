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
      length(var.app_name) <= 17 &&
      can(regex("^[a-zA-Z0-9]+$", var.app_name))
    )
    error_message = "(Required) The application name must be between 2 to 17 characters, only letters and numbers are allowed."
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

variable "kv_id" {
  type        = string
  description = "(Required) ID of the Key Vault to be used to store deploy sensitive data and outputs"

}

# ####OPTIONAL Input Variables
variable "instance_name" {
  type        = string
  description = "(Optional) part of the name to identify this instance of the resource service from other existing ones."
  validation {
    condition = (
      length(var.instance_name) == 0 || (
        length(var.instance_name) >= 0 &&
        length(var.instance_name) <= 25 &&
        can(regex("^[a-zA-Z0-9]+$", var.instance_name))
      )
    )
    error_message = "(Required) The instance name must be between 0 to 25 characters, only letters and numbers are allowed."
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

variable "sku" {
  type        = string
  description = "(Optional) The Name of the SKU used for the Service Bus Namespace. Possible values are basic, standard and premium. Defaults to basic."
  default     = "basic"
  validation {
    condition     = contains(["basic", "standard", "premium"], var.sku)
    error_message = "The Name of the SKU specified must be one of the allowed values (basic, standard, premium)."
  }
}

variable "sku_capacity" {
  type        = number
  description = "(Optional) Specifies the capacity. When sku is Premium, capacity can be 1, 2, 4, 8 or 16. When sku is Basic or Standard, capacity can be 0 only."
  default     = 0
  validation {
    condition     = contains([0, 1, 2, 4, 8, 16], var.sku_capacity)
    error_message = "The capacity specified must be one of the allowed values (0, 1, 2, 4, 8, 16)."
  }
}

variable "zone_redundant" {
  type        = bool
  description = "(Optional) Whether or not this resource is zone redundant. sku needs to be Premium. Defaults to false."
  default     = false
}

variable "sb_allowed_ips" {
  type        = list(string)
  description = "(Optional) List of IP Addresses to allow through the Service Bus Network Rule Set."
  default     = []
}

#Deployment current public IP
data "http" "myip" {
  url = "http://ipv4.icanhazip.com"
}

## Read global config from key vault
data "azurerm_key_vault" "config" {
  name                = var.environment == "pro" ? "KVT-IAC-PRO" : "KVT-IAC-PRE"
  resource_group_name = var.environment == "pro" ? "RG-IAC" : "RG-IAC-PRE"
}
data "azurerm_key_vault_secret" "fw-allowed-ips" {
  name         = "fw-allowed-ips"
  key_vault_id = data.azurerm_key_vault.config.id
}

# Local variables used to reduce repetition 
locals {
  sb_name = var.instance_name != "" ? "SB-${upper(var.app_name)}-${upper(var.instance_name)}-${upper(var.environment)}" : "SB-${upper(var.app_name)}-${upper(var.environment)}"
  sb_fw_ips = distinct(concat(
    var.sb_allowed_ips,
    jsondecode(nonsensitive(data.azurerm_key_vault_secret.fw-allowed-ips.value)),
    [chomp(data.http.myip.body) != "" ? chomp(data.http.myip.body) : null]
  ))
}

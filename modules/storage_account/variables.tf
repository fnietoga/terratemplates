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

# variable "sta_name" {
#   type        = string
#   description = " (Required) Specifies the name of the storage account. Changing this forces a new resource to be created. This must be unique across the entire Azure service, not just within the resource group."
#   validation {
#     condition     = can(regex("^[a-z0-9]{3,24}$", var.sta_name))
#     error_message = "Storage Account name must only contain lowercase letters and numbers, and must be between 3 and 24 alphanumeric characters."
#   }
# }
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

variable "sta_account_kind" {
  type        = string
  description = "(Optional) Defines the Kind of account. Valid options are BlobStorage, BlockBlobStorage, FileStorage, Storage and StorageV2. Changing this forces a new resource to be created. Defaults to StorageV2."
  default     = "StorageV2"
}

variable "sta_account_tier" {
  type        = string
  description = "(Optional) Defines the Tier to use for this storage account. Valid options are Standard and Premium. For BlockBlobStorage and FileStorage accounts only Premium is valid. Changing this forces a new resource to be created. Defaults to Standard."
  default     = "Standard"
  validation {
    condition     = contains(["Standard", "Premium"], var.sta_account_tier)
    error_message = "The Account Tier specified must be one of the allowed values (Standard, Premium)."
  }
}

variable "sta_account_replication_type" {
  type        = string
  description = "(Optional) Defines the type of replication to use for this storage account. Valid options are LRS, GRS, RAGRS, ZRS, GZRS and RAGZRS. Defaults to RAGRS."
  default     = "RAGRS"
  validation {
    condition     = contains(["LRS", "GRS", "RAGRS", "ZRS", "GZRS", "RAGZRS"], var.sta_account_replication_type)
    error_message = "The Replication Type specified must be one of the allowed values (LRS, GRS, RAGRS, ZRS, GZRS and RAGZRS)."
  }
}

variable "sta_access_tier" {
  type        = string
  description = "(Optional) Defines the access tier for BlobStorage, FileStorage and StorageV2 accounts. Valid options are Hot and Cool, defaults to Hot."
  default     = "Hot"
  validation {
    condition     = contains(["Hot", "Cool"], var.sta_access_tier)
    error_message = "The Access Tier specified must be one of the allowed values (Hot, Cool)."
  }
}

variable "sta_allow_blob_public_access" {
  type        = bool
  description = "(Optional) Allow or disallow public access to all blobs or containers in the storage account. Defaults to false."
  default     = false
}

variable "sta_is_hns_enabled" {
  type        = bool
  description = "(Optional) Is Hierarchical Namespace enabled? This can be used with Azure Data Lake Storage Gen 2. Changing this forces a new resource to be created. Defaults to false."
  default     = false
}

variable "sta_allowed_ips" {
  type        = list(string)
  description = "(Optional) List of IP Addresses to allow through the Storage Account firewall."
  default     = []
}

variable "sta_containers" {
  type = list(object({
    name        = string
    access_type = optional(string)
  }))
  description = "(Optional) Object collection with information for containers to be created in the deployed Storage Account."
  default     = []
}

variable "sta_shares" {
  type = list(object({
    name  = string
    quota = optional(number)
  }))
  description = "(Optional) Object collection with information for shares to be created in the deployed Storage Account."
  default     = []
}

variable "sta_tables" {
  type = list(object({
    name = string
  }))
  description = "(Optional) Object collection with information for tables to be created in the deployed Storage Account."
  default     = []
}

variable "sta_queues" {
  type = list(object({
    name = string
  }))
  description = "(Optional) Object collection with information for queues to be created in the deployed Storage Account."
  default     = []
}

#Deployment current public IP
data "http" "myip" {
  url = "http://ipv4.icanhazip.com"

}
## Read global config from key vault
data "azurerm_key_vault" "config" {
  name                = "KVT-IAC-${upper(var.environment)}"
  resource_group_name = var.environment == "pro" ? "RG-IAC" : "RG-IAC-${upper(var.environment)}"
}
data "azurerm_key_vault_secret" "fw-allowed-ips" {
  name         = "fw-allowed-ips"
  key_vault_id = data.azurerm_key_vault.config.id
}

# Local variables used to reduce repetition 
locals {
  sta_name = var.instance_name != "" ? "st${lower(var.app_name)}${lower(var.instance_name)}${lower(var.environment)}" : "st${lower(var.app_name)}${lower(var.environment)}"
  sta_fw_ips = distinct(concat(
    var.sta_allowed_ips,
    jsondecode(nonsensitive(data.azurerm_key_vault_secret.fw-allowed-ips.value)),
    [chomp(data.http.myip.body) != "" ? chomp(data.http.myip.body) : null]
  ))
}

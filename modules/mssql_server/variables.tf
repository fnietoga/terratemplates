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
# variable "server_name" {
#   type        = string
#   description = "(Required) The name of the Microsoft SQL Server. This needs to be globally unique within Azure."
#   validation {
#     condition     = can(regex("^[a-z0-9]{1}[a-z0-9-]{1,61}[a-z0-9]{1}$", var.server_name))
#     error_message = "Server name can contain only lowercase letters, numbers, and hyphen; but can't start or end with hyphen or have more than 63 characters."
#   }
# }

# variable "database_name" {
#   type        = string
#   description = "(Required) The name of the Ms SQL Database. Changing this forces a new resource to be created."
#   validation {
#     condition     =  length(var.database_name) <= 128
#     error_message = "Database name must have a length of at most 128, and can't contain some special characters."
#   }
# }
variable "server_admingroup_name"{
  type = string
  description = "(Required) Name of the Azure AD Group for Administrators of the SQL Server."
}


variable "kv_id" {
  type = string
  description = "(Required) ID of the Key Vault to be used to store deploy sensitive data and outputs"
}

####OPTIONAL Input Variables
variable "instance_name" {
  type        = string
  description = "(Optional) part of the name to identify this instance of the resource service from other existing ones."
  validation {
    condition = (
      length(var.instance_name) >= 2 &&
      length(var.instance_name) <= 6 &&
      can(regex("^[a-zA-Z0-9]+$", var.instance_name))
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

variable "server_administrator_login" {
  type        = string
  description = "(Optional) The administrator login name for the new server. Changing this forces a new resource to be created. Defaults to tradmin"
  default     = "tradmin"
}
variable "server_allowed_ips" {
  type        = list(string)
  description = "(Optional) List of IP Addresses to allow through the SQL Server firewall."
  default     = []
}
variable "database_sku_name" {
  type        = string
  description = "(Optional) Specifies the name of the sku used by the database. Changing this forces a new resource to be created. Defaults to Basic"
  validation {
    condition     = contains(["Basic", "S0", "P2", "DW100c", "DS100", "GP_S_Gen5_2", "HS_Gen4_1", "BC_Gen5_2", "ElasticPool"], var.database_sku_name)
    error_message = "The sku name specified must be one of the allowed values (Basic, S0, P2, DW100c, DS100, GP_S_Gen5_2, HS_Gen4_1, BC_Gen5_2, ElasticPool)."
  }
  default     = "Basic"
}
variable "database_collation" {
  type        = string
  description = "(Optional) Specifies the collation of the database. Changing this forces a new resource to be created. Defaults to SQL_Latin1_General_CP1_CI_AS."
  default     = "SQL_Latin1_General_CP1_CI_AS"
}
variable "database_max_size_gb" {
  type        = number
  description = "(Optional) The max size of the database in gigabytes."
  default     = 0
}

#Deployment current public IP
data "http" "myip" {
  url = "http://ipv4.icanhazip.com"
}

## Read global config from key vault
data "azurerm_key_vault" "config" {
  name                = var.environment == "pro" ? "KVT-IAC-PRO" : "KVT-IAC-PRE2"
  resource_group_name = var.environment == "pro" ? "RG-IAC" : "RG-IAC-PRE"
}
data "azurerm_key_vault_secret" "fw-allowed-ips" {
  name = "fw-allowed-ips"
  key_vault_id = data.azurerm_key_vault.config.id
} 

# Local variables used to reduce repetition 
locals {
  sql_server_name   = var.instance_name != "" ? "dbs-${lower(var.app_name)}-${lower(var.instance_name)}-${lower(var.environment)}" : "dbs-${lower(var.app_name)}-${lower(var.environment)}"
  sql_database_name = var.instance_name != "" ? "DB-${upper(var.app_name)}-${upper(var.instance_name)}-${upper(var.environment)}" : "DB-${upper(var.app_name)}-${upper(var.environment)}"

  server_allowed_ips = distinct(concat(     
    var.server_allowed_ips,
    jsondecode(nonsensitive(data.azurerm_key_vault_secret.fw-allowed-ips.value)),
    [ chomp(data.http.myip.body) != "" ? chomp(data.http.myip.body) : null ]
  ))
}

####REQUIRED Input Variables
variable "resource_group_name" {
  type        = string
  description = "(Required) The name of the resource group in which to create the Resource. Changing this forces a new resource to be created."
}
variable "server_name" {
  type        = string
  description = "(Required) The name of the Microsoft SQL Server. This needs to be globally unique within Azure."
  validation {
    condition     = can(regex("^[a-z0-9]{1}[a-z0-9-]{1,61}[a-z0-9]{1}$", var.server_name))
    error_message = "Server name can contain only lowercase letters, numbers, and hyphen; but can't start or end with hyphen or have more than 63 characters."
  }
}
variable "database_name" {
  type        = string
  description = "(Required) The name of the Ms SQL Database. Changing this forces a new resource to be created."
  validation {
    condition     =  length(var.database_name) <= 128
    error_message = "Database name must have a length of at most 128, and can't contain some special characters."
  }
}
variable "server_admingroup_name"{
  type = string
  description = "(Required) Name of the Azure AD Group for Administrators of the SQL Server."
}


variable "kv_id" {
  type = string
  description = "(Required) ID of the Key Vault to be used to store deploy sensitive data and outputs"
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
  default     = "Basic"
}
# variable "database_license_type" {
#   type        = string
#   description = "(Optional) Specifies the license type applied to this database. Possible values are LicenseIncluded and BasePrice. Defaults to LicenseIncluded."
#   default     = "LicenseIncluded"
# }
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

# Local variables used to reduce repetition 
locals {
  server_deploy_ips = [
    "${chomp(data.http.myip.body)}" != "" ? "${chomp(data.http.myip.body)}" : null
  ]
}

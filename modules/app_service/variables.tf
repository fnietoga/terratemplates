####REQUIRED Input Variables
variable "resource_group_name" {
  type        = string
  description = "(Required) The name of the resource group in which to create the Resource. Changing this forces a new resource to be created."
}
variable "app_name" {
  type        = string
  description = "(Required) Name of the App Service. Changing this forces a new resource to be created."
}
variable "plan_name" {
  type        = string
  description = "(Required) name of the App Service Plan component. Changing this forces a new resource to be created."
}

variable "kv_id" {
  type        = string
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
variable "plan_kind" {
  type        = string
  description = "(Optional) The kind of the App Service Plan to create. Possible values are Windows, Linux and elastic . Defaults to Linux"
  validation {
    condition     = contains(["Windows", "Linux", "elastic"], var.plan_kind)
    error_message = "The kind specified must be one of the allowed values (Windows, Linux, elastic)."
  }
  default = "Linux"
}
variable "plan_reserved" {
  type        = bool
  description = "(Optional) Is this App Service Plan Reserved. Defaults to false."
  default     = false
}
variable "plan_per_site_scaling" {
  type        = bool
  description = "(Optional) Can Apps assigned to this App Service Plan be scaled independently? If set to false apps assigned to this plan will scale to all instances of the plan. Defaults to true"
  default     = true
}
variable "plan_maximum_elastic_worker_count" {
  type        = number
  description = "(Optional) The maximum number of total workers allowed for this ElasticScaleEnabled App Service Plan. Defaults to 2"
  default     = 2
}
variable "plan_sku_tier" {
  type        = string
  description = "(Optional) Specifies the plan's pricing tier. Defaults to PremiumV2."
  default     = "PremiumV2"
  validation {
    condition     = contains(["Basic", "Standard", "PremiumV2"], var.plan_sku_tier)
    error_message = "The sku tier specified must be one of the allowed values (Basic,Standard,PremiumV2)."
  }
}
variable "plan_sku_size" {
  type        = string
  description = "(Optional) Specifies the plan's instance size. Defaults to P1v2."
  default     = "P1v2"
  validation {
    condition     = contains(["F1", "B1", "B2", "B3", "S1", "S2", "S3", "P1v2", "P1v3", "P2v2", "P2v3", "P3v2", "P3v3"], var.plan_sku_size)
    error_message = "The sku size specified must be one of the allowed values (F1, B1, B2, B3, S1, S2, S3, P1v2, P1v3, P2v2, P2v3, P3v2, P3v3)."
  }
}
variable "app_enabled" {
  type        = bool
  description = "(Optional) Is the App Service Enabled?. Defaults to true."
  default     = true
}
variable "app_client_affinity_enabled" {
  type        = bool
  description = "(Optional) Should the App Service send session affinity cookies, which route client requests in the same session to the same instance?. Defaults to false."
  default     = false
}
variable "app_client_cert_enabled" {
  type        = bool
  description = "(Optional) Does the App Service require client certificates for incoming requests? Defaults to false."
  default     = false
}
variable "app_logs_retention_in_days" {
  type        = number
  description = "(Optional) The number of days to retain logs for. Defaults to 7"
  default     = 7
}
variable "app_logs_retention_in_mb" {
  type        = number
  description = "(Optional) The maximum size in megabytes that http log files can use before being removed. Defaults to 35."
  default     = 35
}
variable "app_dotnet_framework_version" {
  type        = string
  description = "(Optional) The version of the .net framework's CLR used in this App Service. Possible values are v2.0, v4.0 and v5.0. Defaults to v4.0."
  validation {
    condition     = contains(["v2.0", "v4.0", "v5.0"], var.app_dotnet_framework_version)
    error_message = "The version of the .net framework's CLR specified must be one of the allowed values (v2.0, v4.0, v5.0)."
  }
  default = "v4.0"
}

variable "app_ftps_state" {
  type        = string
  description = "(Optional) State of FTP / FTPS service for this App Service. Possible valuese: FtpsOnly and Disabled. Defaults to FtpsOnly. "
  validation {
    condition     = contains(["FtpsOnly", "Disabled"], var.app_ftps_state)
    error_message = "The State of FTP / FTPS specified must be one of the allowed values (FtpsOnly, Disabled)."
  }
  default = "FtpsOnly"
}

variable "app_always_on" {
  type        = bool
  description = "(Optional) Should the app be loaded at all times? Defaults to false."
  default     = false
}

variable "app_http2_enabled" {
  type        = bool
  description = "(Optional) Is HTTP2 Enabled on this App Service? Defaults to false."
  default     = false
}
variable "app_use_32_bit_worker_process" {
  type        = bool
  description = "(Optional) Should the App Service run in 32 bit mode, rather than 64 bit mode?. Defaults to false."
  default     = false
}
variable "app_php_version" {
  type = string
  description = "(Optional) The version of PHP to use in this App Service. Possible values are 5.5, 5.6, 7.0, 7.1, 7.2, 7.3 and 7.4."
  validation {
    condition     = contains(["5.5","5.6","7.0","7.1","7.2","7.3","7.4", ""], var.app_php_version)
    error_message = "The version of PHP specified must be one of the allowed values (5.5, 5.6, 7.0, 7.1, 7.2, 7.3, 7.4)."
  }
  default = ""
}

variable "app_python_version" {
   type = string
  description = "(Optional) The version of Python to use in this App Service. Possible values are 2.7 and 3."
  validation {
    condition     = contains(["2.7", "3", ""], var.app_python_version)
    error_message = "The version of PHP specified must be one of the allowed values (2.7, 3)."
  }
  default = ""
}
variable "app_local_mysql_enabled" {
  type        = bool
  description = "(Optional) Is 'MySQL In App' Enabled? This runs a local MySQL instance with your app and shares resources from the App Service plan. Defaults to false."
  default     = false
}

variable "app_slots_names" {
  type = list(string)
  description = "(Optional) List with names for addicional slots to be added to the App Service deployed, with same configuration as the main slot."
  default = []
}
variable "app_allowed_ips" {
  type        = list(string)
  description = "(Optional) List of IP Addresses to allow through the App Service firewall."
  default     = []
}

variable "app_settings" {
  type        = map(any)
  description = "(Optional) A mapping of app settings which should be assigned to the App Service"
  default     = {}
}

variable "ad_app_id" {
  type = string
  description = "(Optional) Application Id of the Azure AD Application registered for App Service authorization."
  default = ""
}

variable "key_vault_secret_id" {
  type = string
  description = "(Optional) The ID of the Key Vault secret. Changing this forces a new resource to be created."
  default = ""
}

variable "custom_hostname" {
  type = string
  description = "(Optional) The hostname to be assigned to the App Service. A CNAME needs to be configured from this Hostname to the Azure Website - otherwise Azure will reject the Hostname Binding."
  default = ""
}

# Local variables used to reduce repetition 
locals {
  app_fw_ips = concat(var.app_allowed_ips, ["${chomp(data.http.myip.body) != "" ? format("%s/%s",chomp(data.http.myip.body),"32") : null}"]) 
}

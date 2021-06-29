####REQUIRED Input Variables
variable "resource_group_name" {
  type        = string
  description = "(Required) The name of the resource group in which to create the Resource. Changing this forces a new resource to be created."
}
variable "name" {
  type        = string
  description = "(Required) Name of the Application Insights component. Changing this forces a new resource to be created."
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

variable "application_type" {
  type        = string
  description = "(Optional) Specifies the type of Application Insights to create. Valid values are ios, java, MobileCenter, Node.JS, other, phone, store and web. Defaults to web."
  validation {
    condition     = contains(["ios", "java", "MobileCenter", "Node.JS", "other", "phone", "store", "web"], var.application_type)
    error_message = "The type specified must be one of the allowed values (ios, java, MobileCenter, Node.JS, other, phone, store, web)."
  }
  default = "web"
}
variable "daily_data_cap_in_gb" {
  type        = number
  description = "(Optional) Specifies the Application Insights component daily data volume cap in GB"
  default     = null
}
variable "retention_in_days" {
  type        = number
  description = "(Optional) Specifies the retention period in days. Possible values are 30, 60, 90, 120, 180, 270, 365, 550 or 730. Defaults to 90."
  validation {
    condition     = contains([30, 60, 90, 120, 180, 270, 365, 550, 730], var.retention_in_days)
    error_message = "The retention days specified must be one of the allowed values (30, 60, 90, 120, 180, 270, 365, 550, 730)."
  }
  default = 90
}
variable "sampling_percentage" {
  type        = number
  description = "(Optional) Specifies the percentage of the data produced by the monitored application that is sampled for Application Insights telemetry."
  default     = null
}
variable "disable_ip_masking" {
  type        = bool
  description = " (Optional) By default the real client ip is masked as 0.0.0.0 in the logs. Use this argument to disable masking and log the real client ip. Defaults to false."
  default     = false
}


# Local variables used to reduce repetition 
locals {
}

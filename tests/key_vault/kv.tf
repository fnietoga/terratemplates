variable "resource_group_name" {
  type        = string
  description = "The name of the resource group in which to create the Resource. Changing this forces a new resource to be created."
  default     = "RG-TERRA-DEV"
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


# Key Vault to store deploy sensitive and iac outputs
module "key_vault" {
  #source = "git::https://github.com/fnietoga/terratemplates.git//modules/key_vault"
  source = "../../modules/key_vault"

  resource_group_name = var.resource_group_name
  azure_location      = var.azure_location
  app_name            = "terra"
  environment         = "dev"
  instance_name       = "fnieto"

  #kv_name             = "terra-kv-dev"
  kv_sku_name = "premium"
  tags = {
    Projecto    = "Terraform Templates"
    Responsable = "fnieto@kabel.es"
    Area        = "Architecture & Operations"
  }
  kv_access_policies = [
    {
      object_id          = "48182787-3831-4e0a-bf5f-21c9226867c8"
      secret_permissions = ["get", "list", "set"]
    }
  ]
  kv_allowed_ips = ["13.95.137.239"]
  kv_certificate_contact_emails = ["fnieto@kabel.es","mmarting@tecnicasreunidas.es"]
}

 
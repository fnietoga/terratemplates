terraform {
  experiments = [module_variable_optional_attrs]
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.64.0"
    }
    http = {
      source  = "hashicorp/http"
      version = "2.1.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "=1.5.1"
    }
  }
  required_version = ">= 0.14.4"
}

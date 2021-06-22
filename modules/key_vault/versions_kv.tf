terraform {
  experiments = [module_variable_optional_attrs]
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.54.0"
    }
    http = {
      source  = "hashicorp/http"
      version = "2.1.0"
    }
  }
  required_version = ">= 1.0"
}
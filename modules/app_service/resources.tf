##TODO: AppSettings by param (collection)
##TODO: create AAD Application for auth
##TODO: Custom host Name & certificates

#Deployment current public IP
data "http" "myip" {
  url = "http://ipv4.icanhazip.com"
}

# Web app plan
resource "azurerm_app_service_plan" "app_plan" {
  name                         = var.plan_name
  location                     = var.azure_location
  resource_group_name          = var.resource_group_name
  kind                         = var.plan_kind
  reserved                     = var.plan_kind == "Linux" ? true : var.plan_reserved
  maximum_elastic_worker_count = 2
  per_site_scaling             = var.plan_per_site_scaling

  sku {
    tier = var.plan_sku_tier
    size = var.plan_sku_size
  }

  tags = var.tags
}

# Web app
resource "azurerm_app_service" "app" {
  name                = var.app_name
  location            = var.azure_location
  resource_group_name = var.resource_group_name
  app_service_plan_id = azurerm_app_service_plan.app_plan.id

  https_only              = true
  enabled                 = var.app_enabled
  client_affinity_enabled = var.app_client_affinity_enabled
  client_cert_enabled     = var.app_client_cert_enabled

  identity {
    type = "SystemAssigned"
  }

  # auth_settings {
  #   enabled          = var.web_clientId != "" ? true : false
  #   default_provider = var.web_clientId != "" ? "AzureActiveDirectory" : null
  #   #runtime_version               = var.web_clientId != "" ? "v2" : null
  #   token_store_enabled           = var.web_clientId != "" ? true : null
  #   issuer                        = var.web_clientId != "" ? "https://sts.windows.net/${data.azurerm_client_config.current.tenant_id}/v2.0" : null
  #   unauthenticated_client_action = var.web_clientId != "" ? "RedirectToLoginPage" : null

  #   dynamic "active_directory" {
  #     for_each = var.web_clientId != "" ? [1] : []
  #     content {
  #       client_id = var.web_clientId

  #     }
  #   }
  # }

  site_config {
    dotnet_framework_version  = var.app_dotnet_framework_version
    ftps_state                = var.app_ftps_state
    always_on                 = var.app_always_on
    min_tls_version           = "1.2"
    http2_enabled             = var.app_http2_enabled
    use_32_bit_worker_process = var.app_use_32_bit_worker_process
    php_version               = var.app_php_version != "" ? var.app_php_version : null
    python_version            = var.app_python_version != "" ? var.app_python_version : null
    local_mysql_enabled       = var.app_local_mysql_enabled
    dynamic "ip_restriction" {
      for_each = local.app_fw_ips
      content {
        ip_address = ip_restriction.value
        name       = "FirewallRule-${ip_restriction.value}"
        action     = "Allow"
        priority   = 100
      }
    }
  }

  # app_settings = {
  #   "ExternalAuth.System.OpenIdConnect.Authority"                = "@Microsoft.KeyVault(VaultName=${azurerm_key_vault.deploy_kv.name};SecretName=OpenIdConnectAuthority)"
  # }

  logs {
    http_logs {
      file_system {
        retention_in_days = var.app_logs_retention_in_days
        retention_in_mb   = var.app_logs_retention_in_mb
      }
    }
  }

  tags = var.tags
}

# Additional slots 
resource "azurerm_app_service_slot" "app_slot" {
  count = length(var.app_slots_names)

  name                = var.app_slots_names[count.index]
  location            = var.azure_location
  resource_group_name = var.resource_group_name
  app_service_name    = azurerm_app_service.app.name
  app_service_plan_id = azurerm_app_service_plan.app_plan.id

  https_only              = true
  enabled                 = var.app_enabled
  client_affinity_enabled = var.app_client_affinity_enabled


  identity {
    type = "SystemAssigned"
  }


  #   # auth_settings {
  #   #   enabled          = var.web_clientId != "" ? true : false
  #   #   default_provider = var.web_clientId != "" ? "AzureActiveDirectory" : null
  #   #   #runtime_version               = var.web_clientId != "" ? "v2" : null
  #   #   token_store_enabled           = var.web_clientId != "" ? true : null
  #   #   unauthenticated_client_action = var.web_clientId != "" ? "RedirectToLoginPage" : null

  #   #   dynamic "active_directory" {
  #   #     for_each = var.web_clientId != "" ? [1] : []
  #   #     content {
  #   #       client_id = var.web_clientId

  #   #     }
  #   #   }
  #   # }

  site_config {
    dotnet_framework_version  = var.app_dotnet_framework_version
    ftps_state                = var.app_ftps_state
    always_on                 = var.app_always_on
    min_tls_version           = "1.2"
    http2_enabled             = var.app_http2_enabled
    use_32_bit_worker_process = var.app_use_32_bit_worker_process
    php_version               = var.app_php_version != "" ? var.app_php_version : null
    python_version            = var.app_python_version != "" ? var.app_python_version : null
    local_mysql_enabled       = var.app_local_mysql_enabled
    dynamic "ip_restriction" {
      for_each = local.app_fw_ips
      content {
        ip_address = ip_restriction.value
        name       = "FirewallRule-${ip_restriction.value}"
        action     = "Allow"
        priority   = 100
      }
    }
  }

  # app_settings = {
  #   "ExternalAuth.System.OpenIdConnect.Authority"                = "@Microsoft.KeyVault(VaultName=${azurerm_key_vault.deploy_kv.name};SecretName=OpenIdConnectAuthority)"
  # }

  logs {
    http_logs {
      file_system {
        retention_in_days = var.app_logs_retention_in_days
        retention_in_mb   = var.app_logs_retention_in_mb
      }
    }
  }

  tags = var.tags

}

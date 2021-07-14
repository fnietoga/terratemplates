#Deployment current context
data "azurerm_client_config" "current" {
}

# Web app plan
resource "azurerm_app_service_plan" "app_plan" {
  name                = local.app_plan_name
  location            = var.azure_location
  resource_group_name = var.resource_group_name
  kind                = var.plan_kind
  reserved            = var.plan_kind == "Linux" ? true : var.plan_reserved
  #maximum_elastic_worker_count = 2
  per_site_scaling = var.plan_per_site_scaling

  sku {
    tier = var.plan_sku_tier
    size = var.plan_sku_size
  }

  tags = var.tags
}

# Web app
resource "azurerm_app_service" "app" {
  name                = local.app_name
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

  auth_settings {
    enabled          = var.ad_app_id != "" ? true : false
    default_provider = var.ad_app_id != "" ? "AzureActiveDirectory" : null
    #runtime_version               = var.ad_app_id != "" ? "v2" : null
    token_store_enabled           = var.ad_app_id != "" ? true : null
    issuer                        = var.ad_app_id != "" ? "https://sts.windows.net/${data.azurerm_client_config.current.tenant_id}/v2.0" : null
    unauthenticated_client_action = var.ad_app_id != "" ? "RedirectToLoginPage" : null
    dynamic "active_directory" {
      for_each = var.ad_app_id != "" ? [1] : []
      content {
        client_id = var.ad_app_id
      }
    }
  }

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
        ip_address = length(split("/", ip_restriction.value)) > 1 ? ip_restriction.value : "${ip_restriction.value}/32"
        name       = "FirewallRule-${ip_restriction.value}"
        action     = "Allow"
        priority   = 100
      }
    }
  }

  app_settings = var.app_settings

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


  auth_settings {
    enabled          = var.ad_app_id != "" ? true : false
    default_provider = var.ad_app_id != "" ? "AzureActiveDirectory" : null
    #runtime_version               = var.ad_app_id != "" ? "v2" : null
    token_store_enabled           = var.ad_app_id != "" ? true : null
    unauthenticated_client_action = var.ad_app_id != "" ? "RedirectToLoginPage" : null
    dynamic "active_directory" {
      for_each = var.ad_app_id != "" ? [1] : []
      content {
        client_id = var.ad_app_id
      }
    }
  }

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
        ip_address = length(split("/", ip_restriction.value)) > 1 ? ip_restriction.value : "${ip_restriction.value}/32"
        name       = "FirewallRule-${ip_restriction.value}"
        action     = "Allow"
        priority   = 100
      }
    }
  }

  app_settings = var.app_settings

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

resource "azurerm_app_service_certificate" "app_certificate" {
  count = var.custom_hostname != "" && var.key_vault_secret_id != "" ? 1 : 0

  name                = "${var.custom_hostname}-cert"
  location            = var.azure_location
  resource_group_name = var.resource_group_name
  key_vault_secret_id = var.key_vault_secret_id
}

resource "azurerm_app_service_custom_hostname_binding" "app_binding" {
  count = var.custom_hostname != "" && var.key_vault_secret_id != "" ? 1 : 0

  hostname            = var.custom_hostname
  app_service_name    = azurerm_app_service.app.name
  resource_group_name = var.resource_group_name

  # Ignore ssl_state and thumbprint as they are managed using
  # azurerm_app_service_certificate_binding.app_certificate_binding
  lifecycle {
    ignore_changes = [ssl_state, thumbprint]
  }
}

resource "azurerm_app_service_certificate_binding" "app_certificate_binding" {
  count = var.custom_hostname != "" && var.key_vault_secret_id != "" ? 1 : 0

  hostname_binding_id = azurerm_app_service_custom_hostname_binding.app_binding[0].id
  certificate_id      = azurerm_app_service_certificate.app_certificate[0].id
  ssl_state           = "SniEnabled"
}

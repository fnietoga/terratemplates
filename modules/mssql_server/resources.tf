#Deployment current context
data "azurerm_client_config" "current" {
}

#SQL Admins group information
data "azuread_group" "server_admins"{
  display_name     = var.server_admingroup_name
  security_enabled = true
}

resource "random_password" "server_admin_password" {
  length      = 20
  upper       = true
  lower       = true
  number      = true
  special     = false
  min_upper   = 5
  min_lower   = 5
  min_numeric = 5
}

resource "azurerm_mssql_server" "server" {
  name                          = local.sql_server_name
  location                      = var.azure_location
  resource_group_name           = var.resource_group_name
  administrator_login           = var.server_administrator_login
  administrator_login_password  = random_password.server_admin_password.result
  version                       = "12.0"
  minimum_tls_version           = "1.2"
  public_network_access_enabled = true

  azuread_administrator {
    login_username = data.azuread_group.server_admins.display_name
    object_id      = data.azuread_group.server_admins.id
    tenant_id      = data.azurerm_client_config.current.tenant_id
  }

  tags = var.tags
}

resource "azurerm_mssql_firewall_rule" "server_fwdeploy" {
  count = length(local.server_allowed_ips) == 0 ? 0 : 1

  name             = "DeploymentIps-${count.index}"
  server_id        = azurerm_mssql_server.server.id
  start_ip_address = local.server_allowed_ips[count.index]
  end_ip_address   = local.server_allowed_ips[count.index]
}

resource "azurerm_mssql_firewall_rule" "server_fwallowed" {
  count = length(var.server_allowed_ips) == 0 ? 0 : 1

  name             = "AllowedIp-${count.index}"
  server_id        = azurerm_mssql_server.server.id
  start_ip_address = var.server_allowed_ips[count.index]
  end_ip_address   = var.server_allowed_ips[count.index]
}

resource "azurerm_mssql_database" "database" {
  name               = local.sql_database_name
  server_id          = azurerm_mssql_server.server.id
  create_mode        = "Default"
  sku_name           = var.database_sku_name
  #license_type       = var.database_license_type
  collation          = var.database_collation
  max_size_gb        = var.database_max_size_gb != 0 ? var.database_max_size_gb : null
  zone_redundant     = false
  read_scale         = false
} 




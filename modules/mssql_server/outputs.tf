output "server-id" {
  value = azurerm_mssql_server.server.id
}
output "server-fqdn" {
  value = azurerm_mssql_server.server.fully_qualified_domain_name
}
output "server-hostname" {
  value = azurerm_mssql_server.server.name
}
output "server-adminusername" {
  value = azurerm_mssql_server.server.administrator_login
}
output "server-adminpassword" {
  value = azurerm_mssql_server.server.administrator_login_password
}
output "database-id" {
  value = azurerm_mssql_database.database.id
}
output "database-name" {
  value = azurerm_mssql_database.database.name
}


#Outputs to KeyVault
resource "azurerm_key_vault_secret" "output_server_id" {
  name         = "mssql-server-${azurerm_mssql_server.server.name}-id"
  value        = azurerm_mssql_server.server.id
  key_vault_id = var.kv_id
}
resource "azurerm_key_vault_secret" "output_server_fqdn" {
  name         = "mssql-server-${azurerm_mssql_server.server.name}-fqdn"
  value        = azurerm_mssql_server.server.fully_qualified_domain_name
  key_vault_id = var.kv_id
}
resource "azurerm_key_vault_secret" "output_server_hostname" {
  name         = "mssql-server-${azurerm_mssql_server.server.name}-hostname"
  value        = azurerm_mssql_server.server.name
  key_vault_id = var.kv_id
}
resource "azurerm_key_vault_secret" "output_server_adminusername" {
  name         = "mssql-server-${azurerm_mssql_server.server.name}-adminusername"
  value        = azurerm_mssql_server.server.administrator_login
  key_vault_id = var.kv_id
}
resource "azurerm_key_vault_secret" "output_server_adminpassword" {
  name         = "mssql-server-${azurerm_mssql_server.server.name}-adminpassword"
  value        = azurerm_mssql_server.server.administrator_login_password
  key_vault_id = var.kv_id
}

resource "azurerm_key_vault_secret" "output_database_id" {
  name         = "mssql-database-${azurerm_mssql_database.database.name}-id"
  value        = azurerm_mssql_database.database.id
  key_vault_id = var.kv_id
}
resource "azurerm_key_vault_secret" "output_database_name" {
  name         = "mssql-database-${azurerm_mssql_database.database.name}-name"
  value        = azurerm_mssql_database.database.name
  key_vault_id = var.kv_id
}
 

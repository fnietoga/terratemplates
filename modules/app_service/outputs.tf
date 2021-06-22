# output "server-id" {
#   value = azurerm_mssql_server.server.id
# }
# output "server-fqdn" {
#   value = azurerm_mssql_server.server.fully_qualified_domain_name
# }
# output "server-hostname" {
#   value = azurerm_mssql_server.server.name
# }
# output "server-adminusername" {
#   value = azurerm_mssql_server.server.administrator_login
# }
# output "server-adminpassword" {
#   value = azurerm_mssql_server.server.administrator_login_password
# }
# output "database-id" {
#   value = azurerm_mssql_database.database.id
# }
# output "database-name" {
#   value = azurerm_mssql_database.database.name
# }


# #Outputs to KeyVault
# resource "azurerm_key_vault_secret" "output_server_id" {
#   name         = "db-server-${azurerm_mssql_server.server.name}-id"
#   value        = azurerm_mssql_server.server.id
#   key_vault_id = var.kv_id
# }
# resource "azurerm_key_vault_secret" "output_server_fqdn" {
#   name         = "db-server-${azurerm_mssql_server.server.name}-fqdn"
#   value        = azurerm_mssql_server.server.fully_qualified_domain_name
#   key_vault_id = var.kv_id
# }
# resource "azurerm_key_vault_secret" "output_server_hostname" {
#   name         = "db-server-${azurerm_mssql_server.server.name}-hostname"
#   value        = azurerm_mssql_server.server.name
#   key_vault_id = var.kv_id
# }
# resource "azurerm_key_vault_secret" "output_server_adminusername" {
#   name         = "db-server-${azurerm_mssql_server.server.name}-adminusername"
#   value        = azurerm_mssql_server.server.administrator_login
#   key_vault_id = var.kv_id
# }
# resource "azurerm_key_vault_secret" "output_server_adminpassword" {
#   name         = "db-server-${azurerm_mssql_server.server.name}-adminpassword"
#   value        = azurerm_mssql_server.server.administrator_login_password
#   key_vault_id = var.kv_id
# }

# resource "azurerm_key_vault_secret" "output_database_id" {
#   name         = "db-database-${azurerm_mssql_database.database.name}-id"
#   value        = azurerm_mssql_database.database.id
#   key_vault_id = var.kv_id
# }
# resource "azurerm_key_vault_secret" "output_database_name" {
#   name         = "db-database-${azurerm_mssql_database.database.name}-name"
#   value        = azurerm_mssql_database.database.name
#   key_vault_id = var.kv_id
# }
 

# #Outputs to KeyVault
# resource "azurerm_key_vault_secret" "appservice_name" {
#   name         = "appservice-name"
#   value        = azurerm_app_service.rpa_app.name
#   key_vault_id = azurerm_key_vault.deploy_kv.id
# }
# resource "azurerm_key_vault_secret" "appservice_productionSlotName" {
#   name         = "appservice-productionSlotName"
#   value        = "production"
#   key_vault_id = azurerm_key_vault.deploy_kv.id
# }
# resource "azurerm_key_vault_secret" "appservice_productionSlotHostName" {
#   name         = "appservice-productionSlotHostName"
#   value        = "https://${azurerm_app_service.rpa_app.default_site_hostname}"
#   key_vault_id = azurerm_key_vault.deploy_kv.id
# }
# resource "azurerm_key_vault_secret" "appservice_stageSlotName" {
#   name         = "appservice-stageSlotName"
#   value        = azurerm_app_service_slot.rpa_app_slot.name
#   key_vault_id = azurerm_key_vault.deploy_kv.id
# }
# resource "azurerm_key_vault_secret" "appservice_stageSlotHostName" {
#   name         = "appservice-stageSlotHostName"
#   value        = "https://${azurerm_app_service_slot.rpa_app_slot.default_site_hostname}"
#   key_vault_id = azurerm_key_vault.deploy_kv.id
# }
# resource "azurerm_key_vault_secret" "appservice_outboundips" {
#   name         = "appservice-outboundips"
#   value        = azurerm_app_service.rpa_app.outbound_ip_addresses
#   key_vault_id = azurerm_key_vault.deploy_kv.id
# }

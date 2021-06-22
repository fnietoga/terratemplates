output "id" {
  value = azurerm_storage_account.sta.id
}
output "name" {
  value = azurerm_storage_account.sta.name
}
output "primary_blob_endpoint" {
  value = azurerm_storage_account.sta.primary_blob_endpoint
}
output "primary_blob_host" {
  value = azurerm_storage_account.sta.primary_blob_host
}
output "primary_queue_endpoint" {
  value = azurerm_storage_account.sta.primary_queue_endpoint
}
output "primary_queue_host" {
  value = azurerm_storage_account.sta.primary_queue_host
}
output "primary_table_endpoint" {
  value = azurerm_storage_account.sta.primary_table_endpoint
}
output "primary_table_host" {
  value = azurerm_storage_account.sta.primary_table_host
}
output "primary_file_endpoint" {
  value = azurerm_storage_account.sta.primary_file_endpoint
}
output "primary_file_host" {
  value = azurerm_storage_account.sta.primary_file_host
}
output "primary_dfs_endpoint" {
  value = azurerm_storage_account.sta.primary_dfs_endpoint
}
output "primary_dfs_host" {
  value = azurerm_storage_account.sta.primary_dfs_host
}
output "primary_access_key" {
  value = azurerm_storage_account.sta.primary_access_key
}

#Outputs to KeyVault
resource "azurerm_key_vault_secret" "output_sta_id" {
  name         = "sta-${azurerm_storage_account.sta.name}-id"
  value        = azurerm_storage_account.sta.id
  key_vault_id = var.kv_id
}
resource "azurerm_key_vault_secret" "output_sta_name" {
  name         = "sta-${azurerm_storage_account.sta.name}-name"
  value        = azurerm_storage_account.sta.name
  key_vault_id = var.kv_id
}
resource "azurerm_key_vault_secret" "output_sta_primary_blob_endpoint" {
  name         = "sta-${azurerm_storage_account.sta.name}-primary-blob-endpoint"
  value        = azurerm_storage_account.sta.primary_blob_endpoint
  key_vault_id = var.kv_id
}
resource "azurerm_key_vault_secret" "output_sta_primary_blob_host" {
  name         = "sta-${azurerm_storage_account.sta.name}-primary-blob-host"
  value        = azurerm_storage_account.sta.primary_blob_host
  key_vault_id = var.kv_id
}
resource "azurerm_key_vault_secret" "output_sta_primary_queue_endpoint" {
  name         = "sta-${azurerm_storage_account.sta.name}-primary-queue-endpoint"
  value        = azurerm_storage_account.sta.primary_queue_endpoint
  key_vault_id = var.kv_id
}
resource "azurerm_key_vault_secret" "output_sta_primary_queue_host" {
  name         = "sta-${azurerm_storage_account.sta.name}-primary-queue-host"
  value        = azurerm_storage_account.sta.primary_queue_host
  key_vault_id = var.kv_id
}
resource "azurerm_key_vault_secret" "output_sta_primary_table_endpoint" {
  name         = "sta-${azurerm_storage_account.sta.name}-primary-table-endpoint"
  value        = azurerm_storage_account.sta.primary_table_endpoint
  key_vault_id = var.kv_id
}
resource "azurerm_key_vault_secret" "output_sta_primary_table_host" {
  name         = "sta-${azurerm_storage_account.sta.name}-primary-table-host"
  value        = azurerm_storage_account.sta.primary_table_host
  key_vault_id = var.kv_id
}
resource "azurerm_key_vault_secret" "output_sta_primary_file_endpoint" {
  name         = "sta-${azurerm_storage_account.sta.name}-primary-file-endpoint"
  value        = azurerm_storage_account.sta.primary_file_endpoint
  key_vault_id = var.kv_id
}
resource "azurerm_key_vault_secret" "output_sta_primary_file_host" {
  name         = "sta-${azurerm_storage_account.sta.name}-primary-file-host"
  value        = azurerm_storage_account.sta.primary_file_host
  key_vault_id = var.kv_id
}
resource "azurerm_key_vault_secret" "output_sta_primary_dfs_endpoint" {
  name         = "sta-${azurerm_storage_account.sta.name}-primary-dfs-endpoint"
  value        = azurerm_storage_account.sta.primary_dfs_endpoint
  key_vault_id = var.kv_id
}
resource "azurerm_key_vault_secret" "output_sta_primary_dfs_host" {
  name         = "sta-${azurerm_storage_account.sta.name}-primary-dfs-host"
  value        = azurerm_storage_account.sta.primary_dfs_host
  key_vault_id = var.kv_id
}
resource "azurerm_key_vault_secret" "output_sta_primary_access_key" {
  name         = "sta-${azurerm_storage_account.sta.name}-primary-access-key"
  value        = azurerm_storage_account.sta.primary_access_key
  key_vault_id = var.kv_id
}
 

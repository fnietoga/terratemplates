output "primary_blob_endpoint" {
  value = azurerm_storage_account.sta.primary_blob_endpoint
}

#Outputs to KeyVault
resource "azurerm_key_vault_secret" "output_sta_primary_blob_endpoint" {
  count        = var.kv_id ? 1 : 0
  name         = "database-server-fqdn"
  value        = azurerm_storage_account.sta.primary_blob_endpoint
  key_vault_id = var.kv_id
}

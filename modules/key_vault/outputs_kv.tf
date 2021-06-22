output "kv_id" {
    value = azurerm_key_vault.deploy_kv.id
}
output "kv_url" {
    value = azurerm_key_vault.deploy_kv.vault_uri
}

#Outputs to KeyVault
resource "azurerm_key_vault_secret" "output_keyvault_id" {
  name         = "keyvault-id"
  value        = azurerm_key_vault.deploy_kv.id
  key_vault_id = azurerm_key_vault.deploy_kv.id
}
resource "azurerm_key_vault_secret" "output_keyvault_url" {
  name         = "keyvault-url"
  value        = azurerm_key_vault.deploy_kv.vault_uri
  key_vault_id = azurerm_key_vault.deploy_kv.id
}


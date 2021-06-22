output "id" {
    value = azurerm_key_vault.deploy_kv.id
}
output "name" {
    value = azurerm_key_vault.deploy_kv.name
}
output "url" {
    value = azurerm_key_vault.deploy_kv.vault_uri
}

#Outputs to KeyVault
resource "azurerm_key_vault_secret" "output_keyvault_id" {
  name         = "keyvault-${azurerm_key_vault.deploy_kv.name}-id"
  value        = azurerm_key_vault.deploy_kv.id
  key_vault_id = azurerm_key_vault.deploy_kv.id
}
resource "azurerm_key_vault_secret" "output_keyvault_name" {
  name         = "keyvault-${azurerm_key_vault.deploy_kv.name}-name"
  value        = azurerm_key_vault.deploy_kv.name
  key_vault_id = azurerm_key_vault.deploy_kv.id
}
resource "azurerm_key_vault_secret" "output_keyvault_url" {
  name         = "keyvault-${azurerm_key_vault.deploy_kv.name}-url"
  value        = azurerm_key_vault.deploy_kv.vault_uri
  key_vault_id = azurerm_key_vault.deploy_kv.id
}
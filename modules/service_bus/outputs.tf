output "id" {
    value = azurerm_servicebus_namespace.namespace.id
}
output "name" {
    value = azurerm_servicebus_namespace.namespace.name
}
output "default_primary_connection_string" {
    value = azurerm_servicebus_namespace.namespace.default_primary_connection_string
}
output "default_secondary_connection_string" {
    value = azurerm_servicebus_namespace.namespace.default_secondary_connection_string
}
output "default_primary_key" {
    value = azurerm_servicebus_namespace.namespace.default_primary_key
}
output "default_secondary_key" {
    value = azurerm_servicebus_namespace.namespace.default_secondary_key
}

#Outputs to KeyVault
resource "azurerm_key_vault_secret" "output_servicebus_id" {
  name         = "keyvault-${azurerm_servicebus_namespace.namespace.name}-id"
  value        = azurerm_servicebus_namespace.namespace.id
  key_vault_id = var.kv_id
}
resource "azurerm_key_vault_secret" "output_servicebus_name" {
  name         = "keyvault-${azurerm_servicebus_namespace.namespace.name}-name"
  value        = azurerm_servicebus_namespace.namespace.name
  key_vault_id = var.kv_id
}
resource "azurerm_key_vault_secret" "output_servicebus_default_primary_connection_string" {
  name         = "keyvault-${azurerm_servicebus_namespace.namespace.name}-default-primary-connection-string"
  value        = azurerm_servicebus_namespace.namespace.default_primary_connection_string
  key_vault_id = var.kv_id
}
resource "azurerm_key_vault_secret" "output_servicebus_default_secondary_connection_string" {
  name         = "keyvault-${azurerm_servicebus_namespace.namespace.name}-default-secondary-connection-string"
  value        = azurerm_servicebus_namespace.namespace.default_secondary_connection_string
  key_vault_id = var.kv_id
}
resource "azurerm_key_vault_secret" "output_servicebus_default_primary_key" {
  name         = "keyvault-${azurerm_servicebus_namespace.namespace.name}-default-primary-key"
  value        = azurerm_servicebus_namespace.namespace.default_primary_key
  key_vault_id = var.kv_id
}
resource "azurerm_key_vault_secret" "output_servicebus_default_secondary_key" {
  name         = "keyvault-${azurerm_servicebus_namespace.namespace.name}-default-secondary-key"
  value        = azurerm_servicebus_namespace.namespace.default_secondary_key
  key_vault_id = var.kv_id
}
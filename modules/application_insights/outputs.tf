output "id" {
  value = azurerm_application_insights.insights.id
}
output "name" {
  value = azurerm_application_insights.insights.name
}
output "app_id" {
  value = azurerm_application_insights.insights.app_id
}
output "instrumentation_key" {
  value = azurerm_application_insights.insights.instrumentation_key
}

# #Outputs to KeyVault
resource "azurerm_key_vault_secret" "output_insights_id" {
  name         = "insights-${azurerm_application_insights.insights.name}-id"
  value        = azurerm_application_insights.insights.id
  key_vault_id = var.kv_id
}
resource "azurerm_key_vault_secret" "output_insights_name" {
  name         = "insights-${azurerm_application_insights.insights.name}-name"
  value        = azurerm_application_insights.insights.name
  key_vault_id = var.kv_id
}
resource "azurerm_key_vault_secret" "output_insights_app_id" {
  name         = "insights-${azurerm_application_insights.insights.name}-app-id"
  value        = azurerm_application_insights.insights.app_id
  key_vault_id = var.kv_id
}
resource "azurerm_key_vault_secret" "output_insights_instrumentation_key" {
  name         = "insights-${azurerm_application_insights.insights.name}-instrumentation_-key"
  value        = azurerm_application_insights.insights.instrumentation_key
  key_vault_id = var.kv_id
} 
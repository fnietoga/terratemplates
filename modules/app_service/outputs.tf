output "plan_id" {
  value = azurerm_app_service_plan.app_plan.id
}
output "app_id" {
  value = azurerm_app_service.app.id
}
output "app_name" {
  value = azurerm_app_service.app.name
}
output "app_custom_domain_verification_id" {
  value =  azurerm_app_service.app.custom_domain_verification_id
}
output "app_default_site_hostname" {
  value =  azurerm_app_service.app.default_site_hostname
}
output "app_outbound_ip_addresses" {
  value =  azurerm_app_service.app.outbound_ip_addresses
}
output "app_outbound_ip_address_list" {
  value =  azurerm_app_service.app.outbound_ip_address_list
}
output "app_identity_principal_id" {
  value =  azurerm_app_service.app.identity[0].principal_id
}  

# #Outputs to KeyVault
resource "azurerm_key_vault_secret" "output_plan_id" {
  name         = "appplan-${azurerm_app_service_plan.app_plan.name}-id"
  value        = azurerm_app_service_plan.app_plan.id
  key_vault_id = var.kv_id
}
resource "azurerm_key_vault_secret" "output_app_id" {
  name         = "appservice-${azurerm_app_service.app.name}-id"
  value        = azurerm_app_service.app.id
  key_vault_id = var.kv_id
}
resource "azurerm_key_vault_secret" "output_app_name" {
  name         = "appservice-${azurerm_app_service.app.name}-name"
  value        = azurerm_app_service.app.name
  key_vault_id = var.kv_id
}
resource "azurerm_key_vault_secret" "output_app_custom_domain_verification_id" {
  name         = "appservice-${azurerm_app_service.app.name}-custom-domain-verification-id"
  value        = azurerm_app_service.app.custom_domain_verification_id
  key_vault_id = var.kv_id
}
resource "azurerm_key_vault_secret" "output_app_default_site_hostname" {
  name         = "appservice-${azurerm_app_service.app.name}-default-site-hostname"
  value        = azurerm_app_service.app.default_site_hostname
  key_vault_id = var.kv_id
}
resource "azurerm_key_vault_secret" "output_app_outbound_ip_addresses" {
  name         = "appservice-${azurerm_app_service.app.name}-outbound-ip-addresses"
  value        = azurerm_app_service.app.outbound_ip_addresses
  key_vault_id = var.kv_id
}
resource "azurerm_key_vault_secret" "output_app_identity_principal_id" {
  name         = "appservice-${azurerm_app_service.app.name}-identity-principal-id"
  value        = azurerm_app_service.app.identity[0].principal_id
  key_vault_id = var.kv_id
} 
resource "azurerm_key_vault_secret" "output_slots_name" {
  for_each = { for slot in azurerm_app_service_slot.app_slot : slot.name => slot }
  
  name         = "appslot-${each.value.app_service_name}-${each.value.name}-name"
  value        = each.value.name
  key_vault_id =  var.kv_id
}
resource "azurerm_key_vault_secret" "output_slots_hostname" {
  for_each = { for slot in azurerm_app_service_slot.app_slot : slot.name => slot }
  
  name         = "appslot-${each.value.app_service_name}-${each.value.name}-hostname"
  value        = each.value.default_site_hostname
  key_vault_id =  var.kv_id
} 
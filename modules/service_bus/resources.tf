#Deployment current context
data "azurerm_client_config" "current" {
}

# Deploy the Service Bus Namespace
resource "azurerm_servicebus_namespace" "namespace" {
  name                = local.sb_name
  location            = var.azure_location
  resource_group_name = var.resource_group_name

  sku            = var.sku
  capacity       = var.sku_capacity
  zone_redundant = var.zone_redundant

  tags = var.tags
}

resource "azurerm_servicebus_namespace_network_rule_set" "namespace_network_rule_set" {
  namespace_name      = azurerm_servicebus_namespace.namespace.name
  resource_group_name = var.resource_group_name

  default_action = "Deny" 
 
  ip_rules = local.sb_fw_ips
}


#Deployment current context
data "azurerm_client_config" "current" {
}
#Deployment current public IP
data "http" "myip" {
  url = "http://ipv4.icanhazip.com"
}

# Deploy the Key Vault 
resource "azurerm_key_vault" "deploy_kv" {
  name                = var.kv_name
  location            = var.azure_location
  resource_group_name = var.resource_group_name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = var.kv_sku_name

  enabled_for_deployment          = var.kv_enabled_for_deployment
  enabled_for_disk_encryption     = var.kv_enabled_for_disk_encryption
  enabled_for_template_deployment = var.kv_enabled_for_template_deployment
  enable_rbac_authorization       = var.kv_enable_rbac_authorization
  purge_protection_enabled        = var.kv_purge_protection_enabled
  soft_delete_retention_days      = var.kv_soft_delete_retention_days
 
  ##Enable firewall and add deployment IP to ensure future modifications
  network_acls {
    bypass         = "None"
    default_action = "Deny"
    ip_rules       = local.kv_fw_ips
  }

  tags = var.tags

}

#Create requested access policies
resource "azurerm_key_vault_access_policy" "kv_acl" {
  for_each = { for acl in var.kv_access_policies : acl.object_id => acl }

  key_vault_id            = azurerm_key_vault.deploy_kv.id
  tenant_id               = data.azurerm_client_config.current.tenant_id
  object_id               = each.value.object_id
  certificate_permissions = each.value.certificate_permissions
  secret_permissions      = each.value.secret_permissions
  key_permissions         = each.value.key_permissions
  storage_permissions     = each.value.storage_permissions
}

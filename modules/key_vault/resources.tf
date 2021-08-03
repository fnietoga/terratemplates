#Deployment current context
data "azurerm_client_config" "current" {
}

# Deploy the Key Vault 
resource "azurerm_key_vault" "deploy_kv" {
  name                = local.kv_name
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

  dynamic "access_policy" {
    for_each = local.kv_access_policies

    content {
      tenant_id               = data.azurerm_client_config.current.tenant_id
      object_id               = access_policy.value.object_id
      certificate_permissions = access_policy.value.certificate_permissions
      secret_permissions      = access_policy.value.secret_permissions
      key_permissions         = access_policy.value.key_permissions
      storage_permissions     = access_policy.value.storage_permissions
    }
  } 

  dynamic "contact" {
    for_each = var.kv_certificate_contact_emails
    content {
      email = contact.value
    }
  }

  tags = var.tags

}

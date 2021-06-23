output "id" {
  value = azurerm_kubernetes_cluster.aks.id
}
output "name" {
  value = azurerm_kubernetes_cluster.aks.name
}
output "fqdn" {
  value = azurerm_kubernetes_cluster.aks.fqdn
}
output "kube_config" {
  value = azurerm_kubernetes_cluster.aks.kube_config
}
output "kube_admin_config" {
  value = azurerm_kubernetes_cluster.aks.kube_admin_config
}
output "node_resource_group" {
  value = azurerm_kubernetes_cluster.aks.node_resource_group
}
# output "effective_outbound_ips" {
#   value = azurerm_kubernetes_cluster.aks.load_balancer_profile.effective_outbound_ips
# }
output "system_managed_principal_id" {
  value = azurerm_kubernetes_cluster.aks.identity[0].principal_id
}

# #Outputs to KeyVault
resource "azurerm_key_vault_secret" "output_aks_id" {
  name         = "aks-${azurerm_kubernetes_cluster.aks.name}-id"
  value        = azurerm_kubernetes_cluster.aks.id
  key_vault_id = var.kv_id
} 
resource "azurerm_key_vault_secret" "output_aks_name" {
  name         = "aks-${azurerm_kubernetes_cluster.aks.name}-name"
  value        = azurerm_kubernetes_cluster.aks.name
  key_vault_id = var.kv_id
} 
resource "azurerm_key_vault_secret" "output_aks_fqdn" {
  name         = "aks-${azurerm_kubernetes_cluster.aks.name}-fqdn"
  value        = azurerm_kubernetes_cluster.aks.fqdn
  key_vault_id = var.kv_id
} 
resource "azurerm_key_vault_secret" "output_kube_config" {
  name         = "aks-${azurerm_kubernetes_cluster.aks.name}-kube-config"
  value        = azurerm_kubernetes_cluster.aks.kube_config_raw
  key_vault_id = var.kv_id
}
resource "azurerm_key_vault_secret" "output_kube_admin_config" {
  name         = "aks-${azurerm_kubernetes_cluster.aks.name}-kube-admin-config"
  value        = azurerm_kubernetes_cluster.aks.kube_admin_config_raw
  key_vault_id = var.kv_id
}  
resource "azurerm_key_vault_secret" "output_node_resource_group" {
  name         = "aks-${azurerm_kubernetes_cluster.aks.name}-node-resource-group"
  value        = azurerm_kubernetes_cluster.aks.node_resource_group
  key_vault_id = var.kv_id
}
# resource "azurerm_key_vault_secret" "output_effective_outbound_ips" {
#   name         = "aks-${azurerm_kubernetes_cluster.aks.name}-effective-outbound-ips"
#   value        = azurerm_kubernetes_cluster.aks.load_balancer_profile.effective_outbound_ips
#   key_vault_id = var.kv_id
# }  
resource "azurerm_key_vault_secret" "output_system_managed_principal_id" {
  name         = "aks-${azurerm_kubernetes_cluster.aks.name}-system-managed-principal-id"
  value        = azurerm_kubernetes_cluster.aks.identity[0].principal_id
  key_vault_id = var.kv_id
}

#Deployment current context
data "azurerm_client_config" "current" {
}
#Get information about AD Group 
data "azuread_group" "aks_admin" {
  display_name     = var.aks_admingroup_name
  security_enabled = true
}
#Get information about subnet
data "azurerm_subnet" "aks_subnet" {
  name                 = local.aks_subnet_name
  virtual_network_name = local.aks_subnet_virtual_network_name
  resource_group_name  = local.aks_subnet_resource_group_name
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                    = var.aks_name
  location                = var.azure_location
  resource_group_name     = var.resource_group_name
  kubernetes_version      = var.kubernetes_version != "" ? var.kubernetes_version : null
  dns_prefix              = local.aks_dns_prefix
  node_resource_group     = local.aks_node_resource_group
  sku_tier                = "Paid"
  private_cluster_enabled = var.private_cluster_enabled 

  identity {
    type = "SystemAssigned"
  }

  default_node_pool {
    name                = "masterlinux"
    type                = "VirtualMachineScaleSets"
    vm_size             = "Standard_DS2_v2" #Revisar si tienen compra
    enable_auto_scaling = var.master_node_pool_enable_auto_scaling
    min_count           = var.master_node_pool_min_count  
    max_count           = var.master_node_pool_max_count 
    node_count          = var.master_node_pool_min_count #initialize with min value
    max_pods            = var.master_node_pool_max_pods   
    vnet_subnet_id      = data.azurerm_subnet.aks_subnet.id
  }

  network_profile {
    network_plugin = "azure"
    #network_policy    = "azure"
    load_balancer_sku = "Standard"
    outbound_type     = "loadBalancer"
  }

  role_based_access_control {
    enabled = true
    azure_active_directory {
      tenant_id              = data.azurerm_client_config.current.tenant_id
      managed                = true
      azure_rbac_enabled     = true ##Requires EnableAzureRBACPreview flag -> https://docs.microsoft.com/en-us/azure/aks/manage-azure-rbac
      admin_group_object_ids = [data.azuread_group.aks_admin.id]
    }
  }

  addon_profile {
    azure_policy {
      enabled = false
    }
    http_application_routing {
      enabled = false
    }
    kube_dashboard {
      enabled = false ##Kubernetes Dashboard addon is deprecated for Kubernetes version >= 1.19.0.
    }
    oms_agent {
      enabled                    = true
      log_analytics_workspace_id = var.oms_workspace_resource_id
    }
  }

  tags = var.tags

}



# resource "azurerm_kubernetes_cluster_node_pool" "aks_masterpool" {
#   name                  = "mainlinux"
#   kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id
#   vm_size               = "Standard_DS2_v2"

#   availability_zones    = ["1", "2", "3"]
#   os_type               = "Linux"
#   enable_node_public_ip = false
#   node_count            = 1
#   max_pods              = 50
#   enable_auto_scaling   = false
#   max_count             = null
#   min_count             = null
#   os_disk_type          = "Managed"
#   os_disk_size_gb       = 64
#   vnet_subnet_id        = azurerm_subnet.aks_subnet.id

#   tags = local.common_tags
# } 


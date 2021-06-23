####REQUIRED Input Variables
variable "resource_group_name" {
  type        = string
  description = "(Required) The name of the resource group in which to create the Resource. Changing this forces a new resource to be created."
}

variable "aks_name" {
  type        = string
  description = "(Required) Name of the AKS Cluster. Changing this forces a new resource to be created."
}
variable "kv_id" {
  type        = string
  description = "(Required) ID of the Key Vault to be used to store deploy sensitive data and outputs"
}
variable "aks_admingroup_name" {
  type        = string
  description = "Name of the AAD Group for AKS Admins"
}
variable "aks_subnet_resourceid" {
  type        = string
  description = "resourceId of the Subnet where the Master Node Pool should exist. Changing this forces a new resource to be created."
}
variable "oms_workspace_resource_id" {
  type        = string
  description = "The Workspace ID of the Log Analytics Workspace which the OMS Agent should send data to."
}
variable "acr_resource_id" {
  type        = string
  description = "The ResourceId of the Azure Container Registry on which to grant AcrPull permission to the AKS cluster"
}

####OPTIONAL Input Variables
variable "azure_location" {
  type        = string
  description = "azure location used for all resources"
  default     = "westeurope"
  validation {
    condition     = index(["westeurope", "northeurope"], var.azure_location) == 0
    error_message = "The location specified must be one of the allowed values."
  }
}
variable "tags" {
  type        = map(any)
  description = "(Optional) A mapping of tags which should be assigned to the resource."
  default     = {}
}

variable "kubernetes_version" {
  type        = string
  description = "Version of Kubernetes specified when creating the AKS managed cluster. If not specified, the latest recommended version will be used at provisioning time"
  default     = "" #1.20.7
}

variable "private_cluster_enabled" {
  type        = bool
  description = "Should this Kubernetes Cluster have its API server only exposed on internal IP addresses? This provides a Private IP Address for the Kubernetes API on the Virtual Network where the Kubernetes Cluster is located. Defaults to false. Changing this forces a new resource to be created."
  default     = false
}

variable "master_node_pool_enable_auto_scaling" {
  type        = bool
  description = "(Optional) Should the Kubernetes Auto Scaler be enabled for this Master Node Pool? Defaults to true."
  default     = true
}
variable "master_node_pool_min_count" {
  type        = number
  description = "he maximum number of nodes which should exist in the Master Node Pool. If specified this must be between 1 and 1000"
  default     = 1
}

variable "master_node_pool_max_count" {
  type        = number
  description = "The minimum number of nodes which should exist in the Master Node Pool. If specified this must be between 1 and 1000"
  default     = 4
}

variable "master_node_pool_max_pods" {
  type        = number
  description = "The maximum number of pods that can run on each agent of the master node pool. Changing this forces a new resource to be created"
  default     = 50
}

# Local variables used to reduce repetition 
locals {
  aks_dns_prefix                  = "${lower(var.aks_name)}-dns"
  aks_node_resource_group         = "${var.resource_group_name}-aks-resources"
  aks_subnet_subscription         = split("/", var.aks_subnet_resourceid)[2]
  aks_subnet_resource_group_name  = split("/", var.aks_subnet_resourceid)[4]
  aks_subnet_virtual_network_name = split("/", var.aks_subnet_resourceid)[8]
  aks_subnet_name                 = split("/", var.aks_subnet_resourceid)[10]
  acr_subscription                = split("/", var.acr_resource_id)[2]
  acr_resource_group              = split("/", var.acr_resource_id)[4]
  acr_name                        = split("/", var.acr_resource_id)[8]
}


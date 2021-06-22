#Deployment current public IP
data "http" "myip" {
  url = "http://ipv4.icanhazip.com"
}

resource "azurerm_storage_account" "sta" {
  name                      = var.sta_name
  resource_group_name       = var.resource_group_name
  location                  = var.azure_location
  account_kind              = var.sta_account_kind
  account_tier              = var.sta_account_tier
  account_replication_type  = var.sta_account_replication_type
  access_tier               = var.sta_access_tier
  enable_https_traffic_only = true
  min_tls_version           = "TLS1_2"
  allow_blob_public_access  = var.sta_allow_blob_public_access
  is_hns_enabled            = var.sta_is_hns_enabled

  network_rules {
    default_action = "Deny"
    bypass         = ["None"] #["Logging","Metrics"]
    ip_rules       = local.sta_deploy_ips
  }

  tags = var.tags
}

resource "azurerm_storage_container" "sta_containers" {
  for_each = { for container in var.sta_containers : container.name => container }

  storage_account_name  = azurerm_storage_account.sta.name
  name                  = each.value.name
  container_access_type = each.value.access_type
}

resource "azurerm_storage_share" "sta_shares" {
  for_each = { for share in var.sta_shares : share.name => share }

  storage_account_name = azurerm_storage_account.sta.name
  name                 = each.value.name
  quota                = each.value.quota
}

resource "azurerm_storage_table" "sta_tables" {
  for_each = { for table in var.sta_tables : table.name => table }

  storage_account_name = azurerm_storage_account.sta.name
  name                 = each.value.name
}


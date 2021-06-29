variable "resource_group_name" {
  type        = string
  description = "The name of the resource group in which to create the Resource. Changing this forces a new resource to be created."
  default     = "RG-TERRA-DEV"
}
variable "azure_location" {
  type        = string
  description = "(Optional) Specifies the supported Azure location where the resource exists. Changing this forces a new resource to be created. Defaults to westeurope."
  default     = "westeurope"
  validation {
    condition     = contains(["westeurope", "northeurope"], var.azure_location)
    error_message = "The location specified must be one of the allowed values (westeurope, northeurope)."
  }
}


# Key Vault to store deploy sensitive and iac outputs
module "key_vault" {
  #source = "git::https://github.com/fnietoga/terratemplates.git//modules/key_vault"
  source = "../modules/key_vault"

  resource_group_name = var.resource_group_name
  azure_location      = var.azure_location
  kv_name             = "terra-kv-dev"
  kv_sku_name         = "premium"
  tags = {
    Projecto    = "Terraform Templates"
    Responsable = "fnieto@kabel.es"
    Area        = "Architecture & Operations"
  }
  kv_access_policies = [
    {
      object_id          = "48182787-3831-4e0a-bf5f-21c9226867c8"
      secret_permissions = ["get", "list", "set"]
    }
  ]
  kv_allowed_ips = ["13.95.137.239"]
}

module "storage_account" {
  #source = "git::https://github.com/fnietoga/terratemplates.git//modules/storage_account"
  source = "../modules/storage_account"

  resource_group_name          = var.resource_group_name
  azure_location               = var.azure_location
  sta_name                     = "terrastadev"
  sta_account_tier             = "Standard"
  sta_account_replication_type = "LRS"
  sta_access_tier              = "Hot"
  sta_allow_blob_public_access = true
  tags = {
    Projecto    = "Terraform Templates"
    Responsable = "fnieto@kabel.es"
    Area        = "Architecture & Operations"
  }
  kv_id          = module.key_vault.id
  sta_containers = [{ name = "backups", access_type = "container" }, { name = "stgconttridentity" }]
  sta_shares     = [{ name = "tridentityfs-tst", quota = 5120 }]
  sta_tables     = [{ name = "logs" }]
  sta_queues     = [{ name = "myqueue" }]
}


module "mssql_server" {
  #source = "git::https://github.com/fnietoga/terratemplates.git//modules/mssql_server"
  source = "../modules/mssql_server"

  resource_group_name    = var.resource_group_name
  azure_location         = var.azure_location
  server_name            = "terra-sql-dev"
  database_name          = "db-tridentity-tst"
  server_admingroup_name = "DBAdmin"
  database_sku_name      = "S0"

  tags = {
    Projecto    = "Terraform Templates"
    Responsable = "fnieto@kabel.es"
    Area        = "Architecture & Operations"
  }
  kv_id = module.key_vault.id

  server_administrator_login = "trdbadmin"
  database_collation         = "SQL_Latin1_General_CP1_CI_AS"
  database_max_size_gb       = 30
}

module "app_service" {
  #source = "git::https://github.com/fnietoga/terratemplates.git//modules/app_service"
  source = "../modules/app_service"

  resource_group_name = var.resource_group_name
  azure_location      = var.azure_location
  app_name            = "terra-app-dev"
  plan_name           = "terra-plan-dev"
  tags = {
    Projecto    = "Terraform Templates"
    Responsable = "fnieto@kabel.es"
    Area        = "Architecture & Operations"
  }
  app_settings = {
    APPINSIGHTS_INSTRUMENTATIONKEY = module.application_insights.instrumentation_key
  }
  kv_id           = module.key_vault.id
  app_slots_names = ["stage"]
  app_allowed_ips = ["1.1.1.1/32", "8.8.8.8/32"]

  ad_app_id = "d1578f5f-ca89-4369-8c7e-66f267ffb551"

  custom_hostname     = "terraform.fnietoga.me"
  key_vault_secret_id = ""
}

module "application_insights" {
  #source = "git::https://github.com/fnietoga/terratemplates.git//modules/application_insights"
  source = "../modules/application_insights"

  resource_group_name  = var.resource_group_name
  azure_location       = var.azure_location
  name                 = "terra-ins-dev"
  application_type     = "web"
  daily_data_cap_in_gb = 10
  disable_ip_masking   = true
  tags = {
    Projecto    = "Terraform Templates"
    Responsable = "fnieto@kabel.es"
    Area        = "Architecture & Operations"
  }
  kv_id = module.key_vault.id

}
 
resource "null_resource" "app_service_ips_sql_firewall" {
  triggers = {
    outbound_ip_addresses = module.app_service.app_outbound_ip_addresses
  }

  provisioner "local-exec" {
    command = <<EOT
      $ips = az webapp show --ids "${module.app_service.app_id}" --query outboundIpAddresses
      [int]$count=0
      foreach ($current in $ips.Split(",")) {
        $currentIP = $($current -replace '"','')
        Write-Host "Creating firewall rule for IP: $currentIP"
        az sql server firewall-rule create --resource-group ${var.resource_group_name} --server ${module.mssql_server.server_hostname} --name ${module.app_service.app_name}-outbound-$($count) --start-ip-address $($currentIP) --end-ip-address $($currentIP)
        $count++
      }
    EOT 

    interpreter = ["pwsh", "-Command"]
  }
}

#############
## D E V
#############
$clientId = '2eb722dc-e6c8-4046-b2ad-8bd1bccaf192'; ##fnietokabel-deploy
$clientKey = Get-Secret -Name 'fnieto_fnietokabel-deploy' -AsPlainText
$tenantId = '9d326c83-750e-4534-9037-94b786446bf0'; ##fnietokabel.onmicrosoft.com
$subscriptionId = '841bc417-7db7-4e2e-82d3-c80bd04ab305'##Visual Studio Enterprise con MSDN
$Credentials = New-Object System.Management.Automation.PSCredential -ArgumentList $clientId, ($clientKey | ConvertTo-SecureString -AsPlainText -Force); $token = ((Invoke-WebRequest -Uri $('https://login.windows.net/' + $tenantId + '/oauth2/token') -Method 'POST' -Headers @{contentype = 'application/json'; Metadata = 'true' } -Body  @{resource = 'https://graph.windows.net/'; grant_type = 'client_credentials'; client_id = $clientId; client_secret = $clientKey } -UseBasicParsing).Content | ConvertFrom-Json).access_token; Connect-AzAccount -TenantId $tenantId -ServicePrincipal -Credential $Credentials -Subscription $subscriptionId;
az login --service-principal --username $clientId --password $clientKey --tenant $tenantId
az account set --subscription $subscriptionId
[Console]::ResetColor()

#$Env:TF_DATA_DIR = Join-Path -Path $(Get-Location) -ChildPath .terraform
$Env:TF_LOG = "" ##set "trace" value for debug purposes

$Env:ARM_CLIENT_ID = $clientId
$Env:ARM_CLIENT_SECRET = $clientKey
$Env:ARM_SUBSCRIPTION_ID = $subscriptionId
$Env:ARM_TENANT_ID = $tenantId

terraform init -upgrade 
terraform validate
terraform plan -out .terraform/templates.tfplan
terraform apply -auto-approve ".terraform/templates.tfplan"

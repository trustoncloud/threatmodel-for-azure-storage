# Storage.C163 (sftp_local_user_detection) - universal - VIOLATING

# SFTP and local users both enabled: 2 findings
resource "azurerm_storage_account" "insecure" {
  name                     = "insecure-acct"
  resource_group_name      = "rg-test"
  location                 = "eastus"
  account_tier             = "Standard"
  account_replication_type = "LRS"
  sftp_enabled             = true
  local_user_enabled       = true
}

# Storage.C163 (sftp_local_user_detection) - universal - COMPLIANT (0 findings)

# SFTP and local users both disabled
resource "azurerm_storage_account" "secure" {
  name                     = "secure-acct"
  resource_group_name      = "rg-test"
  location                 = "eastus"
  account_tier             = "Standard"
  account_replication_type = "LRS"
  sftp_enabled             = false
  local_user_enabled       = false
}

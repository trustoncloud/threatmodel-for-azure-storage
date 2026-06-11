# Storage.C163 (sftp_local_user_detection) - allowlist - COMPLIANT (0 findings)

# Authorized account may have SFTP + local users enabled
resource "azurerm_storage_account" "authorized_sftp" {
  name                     = "vendor-upload-share"
  resource_group_name      = "rg-test"
  location                 = "eastus"
  account_tier             = "Standard"
  account_replication_type = "LRS"
  sftp_enabled             = true
  local_user_enabled       = true
}

# Normal account with both disabled
resource "azurerm_storage_account" "secure" {
  name                     = "secure-acct"
  resource_group_name      = "rg-test"
  location                 = "eastus"
  account_tier             = "Standard"
  account_replication_type = "LRS"
  sftp_enabled             = false
  local_user_enabled       = false
}

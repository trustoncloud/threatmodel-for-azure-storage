# Storage.C163 (sftp_local_user_detection) - universal - COMPLIANT

# SFTP off; local users at their default cannot sign in
resource "azurerm_storage_account" "no_sftp" {
  name                     = "examplenosftp"
  resource_group_name      = "example-rg"
  location                 = "eastus"
  account_tier             = "Standard"
  account_replication_type = "LRS"
  is_hns_enabled           = true
}

# SFTP on, local users off
resource "azurerm_storage_account" "sftp_no_local_users" {
  name                     = "examplesftpnousers"
  resource_group_name      = "example-rg"
  location                 = "eastus"
  account_tier             = "Standard"
  account_replication_type = "LRS"
  is_hns_enabled           = true
  sftp_enabled             = true
  local_user_enabled       = false
}

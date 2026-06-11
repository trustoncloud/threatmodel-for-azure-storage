# Storage.C163 (sftp_local_user_detection) - allowlist - VIOLATING

# Non-authorized account with SFTP enabled: 1 finding
resource "azurerm_storage_account" "rogue_sftp" {
  name                     = "rogue-sftp"
  resource_group_name      = "rg-test"
  location                 = "eastus"
  account_tier             = "Standard"
  account_replication_type = "LRS"
  sftp_enabled             = true
}

# Non-authorized account with local users enabled: 1 finding
resource "azurerm_storage_account" "rogue_localuser" {
  name                     = "rogue-localuser"
  resource_group_name      = "rg-test"
  location                 = "eastus"
  account_tier             = "Standard"
  account_replication_type = "LRS"
  local_user_enabled       = true
}

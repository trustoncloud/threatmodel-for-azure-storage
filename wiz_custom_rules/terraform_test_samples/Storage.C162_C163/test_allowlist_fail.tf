# Storage.C163 (sftp_local_user_detection) - allowlist - VIOLATING

# Unauthorized account with SFTP, local users on by default: 1 finding
resource "azurerm_storage_account" "rogue_sftp" {
  name                     = "exampleroguesftp"
  resource_group_name      = "example-rg"
  location                 = "eastus"
  account_tier             = "Standard"
  account_replication_type = "LRS"
  is_hns_enabled           = true
  sftp_enabled             = true
}

# Local user allowed to sign in with a password: 1 finding
resource "azurerm_storage_account_local_user" "password_user" {
  name                 = "examplepassworduser"
  storage_account_id   = azurerm_storage_account.rogue_sftp.id
  ssh_key_enabled      = true
  ssh_password_enabled = true

  ssh_authorized_key {
    key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJEAC86WUl23i3Fb98LXfRiIqhWrk3ARrd2RwLFsnVbS example"
  }
}

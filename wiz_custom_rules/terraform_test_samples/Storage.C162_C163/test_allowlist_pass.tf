# Storage.C163 (sftp_local_user_detection) - allowlist - COMPLIANT

# Authorized account with SFTP and a key-only local user
resource "azurerm_storage_account" "authorized_sftp" {
  name                     = "examplevendorupload"
  resource_group_name      = "example-rg"
  location                 = "eastus"
  account_tier             = "Standard"
  account_replication_type = "LRS"
  is_hns_enabled           = true
  sftp_enabled             = true
  local_user_enabled       = true
}

resource "azurerm_storage_account_local_user" "vendor" {
  name                 = "examplevendor"
  storage_account_id   = azurerm_storage_account.authorized_sftp.id
  ssh_key_enabled      = true
  ssh_password_enabled = false

  ssh_authorized_key {
    key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJEAC86WUl23i3Fb98LXfRiIqhWrk3ARrd2RwLFsnVbS example"
  }
}

# Local users left at their default, SFTP off: nobody can sign in
resource "azurerm_storage_account" "no_sftp" {
  name                     = "examplenosftp"
  resource_group_name      = "example-rg"
  location                 = "eastus"
  account_tier             = "Standard"
  account_replication_type = "LRS"
  is_hns_enabled           = true
}

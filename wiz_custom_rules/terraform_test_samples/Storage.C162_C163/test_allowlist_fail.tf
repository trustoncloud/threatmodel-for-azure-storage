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

# Authorized account for the local user cases below: SFTP is allowed here
resource "azurerm_storage_account" "authorized_sftp" {
  name                     = "examplevendorupload"
  resource_group_name      = "example-rg"
  location                 = "eastus"
  account_tier             = "Standard"
  account_replication_type = "LRS"
  is_hns_enabled           = true
  sftp_enabled             = true
}

# Key-only local user on an account that is not authorized for SFTP: 1 finding
resource "azurerm_storage_account_local_user" "key_user_rogue_account" {
  name               = "examplevendor"
  storage_account_id = azurerm_storage_account.rogue_sftp.id
  ssh_key_enabled    = true

  ssh_authorized_key {
    key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJEAC86WUl23i3Fb98LXfRiIqhWrk3ARrd2RwLFsnVbS example"
  }
}

# Local user that is not in the authorized list: 1 finding
resource "azurerm_storage_account_local_user" "unlisted_user" {
  name               = "exampleroguser"
  storage_account_id = azurerm_storage_account.authorized_sftp.id
  ssh_key_enabled    = true

  ssh_authorized_key {
    key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJEAC86WUl23i3Fb98LXfRiIqhWrk3ARrd2RwLFsnVbS example"
  }
}

# Authorized local user granted the delete permission: 1 finding
resource "azurerm_storage_account_local_user" "delete_user" {
  name               = "examplevendor"
  storage_account_id = azurerm_storage_account.authorized_sftp.id
  ssh_key_enabled    = true

  ssh_authorized_key {
    key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJEAC86WUl23i3Fb98LXfRiIqhWrk3ARrd2RwLFsnVbS example"
  }

  permission_scope {
    service       = "blob"
    resource_name = "inbound"

    permissions {
      read   = true
      list   = true
      delete = true
    }
  }
}

# Account ID supplied at apply time, so the account is unknown: 1 finding
variable "vendor_account_id" {
  type = string
}

resource "azurerm_storage_account_local_user" "unknown_account_user" {
  name               = "examplevendor"
  storage_account_id = var.vendor_account_id
  ssh_key_enabled    = true

  ssh_authorized_key {
    key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJEAC86WUl23i3Fb98LXfRiIqhWrk3ARrd2RwLFsnVbS example"
  }
}

# Literal ID of an account whose name only starts with an authorized name: 1 finding
resource "azurerm_storage_account_local_user" "lookalike_account_user" {
  name               = "examplevendor"
  storage_account_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/example-rg/providers/Microsoft.Storage/storageAccounts/examplevendoruploads"
  ssh_key_enabled    = true

  ssh_authorized_key {
    key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJEAC86WUl23i3Fb98LXfRiIqhWrk3ARrd2RwLFsnVbS example"
  }
}

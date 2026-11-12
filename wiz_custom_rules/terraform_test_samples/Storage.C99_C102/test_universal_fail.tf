# Storage.C102 (file_share_smb21_required) - universal - VIOLATING

variable "unknown_account_kind" {
  type = string
}

variable "unknown_protocol" {
  type = string
}

# SMB2.1 enabled (globally forbidden): 1 finding
resource "azurerm_storage_account" "smb21_present" {
  name                     = "exampleanyshare"
  resource_group_name      = "rg-test"
  location                 = "eastus"
  account_tier             = "Standard"
  account_replication_type = "LRS"

  share_properties {
    smb {
      versions = ["SMB2.1"]
    }
  }
}

# share_properties omitted, account_kind omitted (StorageV2): Azure default allows SMB2.1: 1 finding
resource "azurerm_storage_account" "default_smb" {
  name                     = "exampledefaultshare"
  resource_group_name      = "rg-test"
  location                 = "eastus"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# smb block without versions: 1 finding
resource "azurerm_storage_account" "smb_no_versions" {
  name                     = "examplenoversions"
  resource_group_name      = "rg-test"
  location                 = "eastus"
  account_tier             = "Standard"
  account_replication_type = "LRS"

  share_properties {
    smb {
      kerberos_ticket_encryption_type = ["AES-256"]
    }
  }
}

# account_kind not resolved by the source scan, share_properties omitted: 1 finding
resource "azurerm_storage_account" "unknown_kind" {
  name                     = "exampleunknownkind"
  resource_group_name      = "rg-test"
  location                 = "eastus"
  account_kind             = var.unknown_account_kind
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# NFS share: 1 finding
resource "azurerm_storage_share" "nfs_share" {
  name               = "nfsshare"
  storage_account_id = azurerm_storage_account.smb21_present.id
  quota              = 100
  enabled_protocol   = "NFS"
}

# Share protocol not resolved by the source scan: 1 finding
resource "azurerm_storage_share" "unknown_protocol" {
  name               = "unknownprotocol"
  storage_account_id = azurerm_storage_account.smb21_present.id
  quota              = 100
  enabled_protocol   = var.unknown_protocol
}

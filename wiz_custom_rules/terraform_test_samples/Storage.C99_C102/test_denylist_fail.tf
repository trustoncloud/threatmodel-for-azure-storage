# Storage.C102 (file_share_smb21_required) - denylist - VIOLATING

variable "unknown_versions" {
  type = list(string)
}

# Forbidden SMB2.1 present: 1 finding
resource "azurerm_storage_account" "forbidden_smb" {
  name                     = "exampleanyshare"
  resource_group_name      = "rg-test"
  location                 = "eastus"
  account_tier             = "Standard"
  account_replication_type = "LRS"

  share_properties {
    smb {
      versions = ["SMB3.0", "SMB2.1"]
    }
  }
}

# share_properties omitted: the Azure default allows SMB2.1: 1 finding
resource "azurerm_storage_account" "default_smb" {
  name                     = "exampledefaultshare"
  resource_group_name      = "rg-test"
  location                 = "eastus"
  account_kind             = "StorageV2"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# versions not resolved by the source scan: 1 finding
resource "azurerm_storage_account" "unknown_versions" {
  name                     = "exampleunknownvers"
  resource_group_name      = "rg-test"
  location                 = "eastus"
  account_tier             = "Standard"
  account_replication_type = "LRS"

  share_properties {
    smb {
      versions = var.unknown_versions
    }
  }
}

# NFS share (forbidden protocol): 1 finding
resource "azurerm_storage_share" "nfs_share" {
  name               = "nfsshare"
  storage_account_id = azurerm_storage_account.forbidden_smb.id
  quota              = 100
  enabled_protocol   = "NFS"
}

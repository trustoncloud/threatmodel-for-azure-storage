# Storage.C102 (file_share_smb21_required) - allowlist - VIOLATING

variable "unknown_account_kind" {
  type = string
}

variable "unknown_share_account_id" {
  type = string
}

# SMB2.1 enabled on a non-authorized account: 1 finding
resource "azurerm_storage_account" "smb21_unauthorized" {
  name                     = "exampleprodshare"
  resource_group_name      = "rg-test"
  location                 = "eastus"
  account_tier             = "Standard"
  account_replication_type = "LRS"

  share_properties {
    smb {
      versions = ["SMB2.1", "SMB3.0"]
    }
  }
}

# share_properties omitted on a StorageV2 account: the Azure default allows SMB2.1: 1 finding
resource "azurerm_storage_account" "default_smb" {
  name                     = "exampledefaultshare"
  resource_group_name      = "rg-test"
  location                 = "eastus"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# smb block without versions: the Azure default allows SMB2.1: 1 finding
resource "azurerm_storage_account" "smb_no_versions" {
  name                     = "examplenoversions"
  resource_group_name      = "rg-test"
  location                 = "eastus"
  account_tier             = "Standard"
  account_replication_type = "LRS"

  share_properties {
    smb {
      channel_encryption_type = ["AES-256-GCM"]
    }
  }
}

# Account named like an authorized one is not authorized: 1 finding
resource "azurerm_storage_account" "lookalike_name" {
  name                     = "examplelegacyapp2"
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

# account_kind not resolved by the source scan, share_properties omitted: 1 finding
resource "azurerm_storage_account" "unknown_kind" {
  name                     = "exampleunknownkind"
  resource_group_name      = "rg-test"
  location                 = "eastus"
  account_kind             = var.unknown_account_kind
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# FileStorage account for NFS, versions limited to SMB 3: 0 findings on the account
resource "azurerm_storage_account" "nfs_host" {
  name                     = "examplenfshost"
  resource_group_name      = "rg-test"
  location                 = "eastus"
  account_kind             = "FileStorage"
  account_tier             = "Premium"
  account_replication_type = "LRS"

  share_properties {
    smb {
      versions = ["SMB3.1.1"]
    }
  }
}

# NFS share on a non-authorized account (reference): 1 finding
resource "azurerm_storage_share" "nfs_unauthorized" {
  name               = "nfsunauthorized"
  storage_account_id = azurerm_storage_account.nfs_host.id
  quota              = 100
  enabled_protocol   = "NFS"
}

# NFS share on an account ID whose name only looks like an authorized one: 1 finding
resource "azurerm_storage_share" "nfs_lookalike_id" {
  name               = "nfslookalike"
  storage_account_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Storage/storageAccounts/examplelegacyapp2"
  quota              = 100
  enabled_protocol   = "NFS"
}

# NFS share whose account is not resolved by the source scan: 1 finding
resource "azurerm_storage_share" "nfs_unknown_account" {
  name               = "nfsunknown"
  storage_account_id = var.unknown_share_account_id
  quota              = 100
  enabled_protocol   = "NFS"
}

# Storage.C102 (file_share_smb21_required) - allowlist - COMPLIANT (0 findings)

# SMB2.1 on an authorized account
resource "azurerm_storage_account" "smb21_authorized" {
  name                     = "examplelegacyapp"
  resource_group_name      = "rg-test"
  location                 = "eastus"
  account_kind             = "FileStorage"
  account_tier             = "Premium"
  account_replication_type = "LRS"

  share_properties {
    smb {
      versions = ["SMB2.1", "SMB3.0"]
    }
  }
}

# Modern SMB only (no SMB2.1) on a non-authorized account
resource "azurerm_storage_account" "modern_smb" {
  name                     = "exampleprodshare"
  resource_group_name      = "rg-test"
  location                 = "eastus"
  account_tier             = "Standard"
  account_replication_type = "LRS"

  share_properties {
    smb {
      versions = ["SMB3.0", "SMB3.1.1"]
    }
  }
}

# Block blob account: no file service
resource "azurerm_storage_account" "block_blob" {
  name                     = "exampleblockblob"
  resource_group_name      = "rg-test"
  location                 = "eastus"
  account_kind             = "BlockBlobStorage"
  account_tier             = "Premium"
  account_replication_type = "LRS"
}

# NFS share on the authorized account (reference)
resource "azurerm_storage_share" "nfs_authorized_ref" {
  name               = "nfsauthorizedref"
  storage_account_id = azurerm_storage_account.smb21_authorized.id
  quota              = 100
  enabled_protocol   = "NFS"
}

# NFS share on the authorized account (literal ARM ID)
resource "azurerm_storage_share" "nfs_authorized_id" {
  name               = "nfsauthorizedid"
  storage_account_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Storage/storageAccounts/examplelegacyapp"
  quota              = 100
  enabled_protocol   = "NFS"
}

# SMB share (the default protocol) on a non-authorized account
resource "azurerm_storage_share" "smb_share" {
  name               = "smbshare"
  storage_account_id = azurerm_storage_account.modern_smb.id
  quota              = 50
}

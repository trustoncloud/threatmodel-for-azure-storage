# Storage.C102 (file_share_smb21_required) - universal - COMPLIANT (0 findings)

# Modern SMB only (SMB 3.0+)
resource "azurerm_storage_account" "modern_smb_only" {
  name                     = "exampleanyshare"
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

# SMB share (the default protocol)
resource "azurerm_storage_share" "smb_share" {
  name               = "smbshare"
  storage_account_id = azurerm_storage_account.modern_smb_only.id
  quota              = 50
}

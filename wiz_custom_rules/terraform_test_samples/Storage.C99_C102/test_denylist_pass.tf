# Storage.C102 (file_share_smb21_required) - denylist - COMPLIANT (0 findings)

# No forbidden SMB version present
resource "azurerm_storage_account" "no_forbidden_smb" {
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

# SMB share, protocol set explicitly
resource "azurerm_storage_share" "smb_share" {
  name               = "smbshare"
  storage_account_id = azurerm_storage_account.no_forbidden_smb.id
  quota              = 50
  enabled_protocol   = "SMB"
}

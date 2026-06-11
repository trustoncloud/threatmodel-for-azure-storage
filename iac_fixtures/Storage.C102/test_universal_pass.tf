# Storage.C102 (file_share_smb21_required) - universal - COMPLIANT (0 findings)

# Modern SMB only (SMB 3.0+)
resource "azurerm_storage_account" "modern_smb_only" {
  name                     = "any-share"
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

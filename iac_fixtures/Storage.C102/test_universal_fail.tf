# Storage.C102 (file_share_smb21_required) - universal - VIOLATING

# SMB2.1 enabled (globally forbidden): 1 finding
resource "azurerm_storage_account" "smb21_present" {
  name                     = "any-share"
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

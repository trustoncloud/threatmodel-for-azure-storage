# Storage.C102 (file_share_smb21_required) - denylist - VIOLATING

# Forbidden SMB2.1 present: 1 finding
resource "azurerm_storage_account" "forbidden_smb" {
  name                     = "any-share"
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

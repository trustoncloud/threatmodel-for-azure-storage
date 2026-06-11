# Storage.C102 (file_share_smb21_required) - denylist - COMPLIANT (0 findings)

# No forbidden SMB version present
resource "azurerm_storage_account" "no_forbidden_smb" {
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

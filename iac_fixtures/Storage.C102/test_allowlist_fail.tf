# Storage.C102 (file_share_smb21_required) - allowlist - VIOLATING

# SMB2.1 enabled on a non-authorized account: 1 finding
resource "azurerm_storage_account" "smb21_unauthorized" {
  name                     = "prod-share"
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

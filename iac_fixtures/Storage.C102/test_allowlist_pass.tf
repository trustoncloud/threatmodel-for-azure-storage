# Storage.C102 (file_share_smb21_required) - allowlist - COMPLIANT (0 findings)

# SMB2.1 on an authorized account
resource "azurerm_storage_account" "smb21_authorized" {
  name                     = "legacy-app-storage"
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

# Modern SMB only (no SMB2.1) on a non-authorized account
resource "azurerm_storage_account" "modern_smb" {
  name                     = "prod-share"
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

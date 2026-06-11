# Storage.C97 (cors_trusted_origins_detection) - universal - COMPLIANT (0 findings)
# Universal mode requires CORS to be disabled entirely.

resource "azurerm_storage_account" "no_cors" {
  name                     = "nocorsuniversal"
  resource_group_name      = "rg-test"
  location                 = "eastus"
  account_tier             = "Standard"
  account_replication_type = "LRS"

  # blob_properties present but with no cors_rule is fine
  blob_properties {
    versioning_enabled = true
  }
}

# Storage.C97 (cors_trusted_origins_detection) - universal - VIOLATING
# Any cors_rule present is a violation in universal mode.

resource "azurerm_storage_account" "has_cors" {
  name                     = "hascorsuniversal"
  resource_group_name      = "rg-test"
  location                 = "eastus"
  account_tier             = "Standard"
  account_replication_type = "LRS"

  blob_properties {
    cors_rule {
      allowed_origins    = ["https://myapp.contoso.com"]
      allowed_methods    = ["GET"]
      allowed_headers    = ["Content-Type"]
      exposed_headers    = ["x-ms-request-id"]
      max_age_in_seconds = 100
    }
  }
}

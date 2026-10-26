# Storage.C97 (cors_trusted_origins_detection) - allowlist - COMPLIANT (0 findings)

# Fully authorized CORS rule (origins, methods, headers, exposed, max_age all allowed)
resource "azurerm_storage_account" "compliant_cors" {
  name                     = "compliantcors"
  resource_group_name      = "rg-test"
  location                 = "eastus"
  account_tier             = "Standard"
  account_replication_type = "LRS"

  blob_properties {
    cors_rule {
      allowed_origins    = ["https://myapp.contoso.com", "https://api.contoso.com"]
      allowed_methods    = ["GET", "POST"]
      allowed_headers    = ["Content-Type"]
      exposed_headers    = ["x-ms-request-id"]
      max_age_in_seconds = 200
    }
  }
}

# No CORS configured at all (also compliant)
resource "azurerm_storage_account" "no_cors" {
  name                     = "nocorsacct"
  resource_group_name      = "rg-test"
  location                 = "eastus"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

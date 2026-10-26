# Storage.C97 (cors_trusted_origins_detection) - allowlist - VIOLATING

# Unauthorized origin + unauthorized method + max_age over cap (blob): 3 findings
resource "azurerm_storage_account" "violating_cors_blob" {
  name                     = "violatingcorsblob"
  resource_group_name      = "rg-test"
  location                 = "eastus"
  account_tier             = "Standard"
  account_replication_type = "LRS"

  blob_properties {
    cors_rule {
      allowed_origins    = ["https://evil.example.com"]
      allowed_methods    = ["DELETE"]
      allowed_headers    = ["Content-Type"]
      exposed_headers    = ["x-ms-request-id"]
      max_age_in_seconds = 500
    }
  }
}

# Unauthorized request header in the share service: 1 finding
resource "azurerm_storage_account" "violating_cors_share" {
  name                     = "violatingcorsshare"
  resource_group_name      = "rg-test"
  location                 = "eastus"
  account_tier             = "Standard"
  account_replication_type = "LRS"

  share_properties {
    cors_rule {
      allowed_origins    = ["https://myapp.contoso.com"]
      allowed_methods    = ["GET"]
      allowed_headers    = ["X-Custom-Secret"]
      exposed_headers    = ["x-ms-request-id"]
      max_age_in_seconds = 100
    }
  }
}

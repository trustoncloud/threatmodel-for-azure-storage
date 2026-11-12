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

# Queue CORS set on the standalone resource, unauthorized origin: 1 finding
resource "azurerm_storage_account" "violating_cors_queue" {
  name                     = "violatingcorsqueue"
  resource_group_name      = "rg-test"
  location                 = "eastus"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_account_queue_properties" "violating_cors_queue" {
  storage_account_id = azurerm_storage_account.violating_cors_queue.id

  cors_rule {
    allowed_origins    = ["https://myapp.contoso.com.evil.example"]
    allowed_methods    = ["GET"]
    allowed_headers    = ["Content-Type"]
    exposed_headers    = ["x-ms-request-id"]
    max_age_in_seconds = 100
  }
}

# Table CORS set on the standalone resource, unauthorized method: 1 finding
resource "azurerm_storage_account" "violating_cors_table" {
  name                     = "violatingcorstable"
  resource_group_name      = "rg-test"
  location                 = "eastus"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_account_table_properties" "violating_cors_table" {
  storage_account_id = azurerm_storage_account.violating_cors_table.id

  cors_rule {
    allowed_origins    = ["https://api.contoso.com"]
    allowed_methods    = ["DELETE"]
    allowed_headers    = ["Content-Type"]
    exposed_headers    = ["x-ms-request-id"]
    max_age_in_seconds = 100
  }
}

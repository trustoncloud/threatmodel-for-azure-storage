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

# Queue CORS set on the standalone resource: 1 finding
resource "azurerm_storage_account" "queue_cors" {
  name                     = "queuecorsuniversal"
  resource_group_name      = "rg-test"
  location                 = "eastus"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_account_queue_properties" "queue_cors" {
  storage_account_id = azurerm_storage_account.queue_cors.id

  cors_rule {
    allowed_origins    = ["https://myapp.contoso.com"]
    allowed_methods    = ["GET"]
    allowed_headers    = ["Content-Type"]
    exposed_headers    = ["x-ms-request-id"]
    max_age_in_seconds = 100
  }
}

# Table CORS set on the standalone resource: 1 finding
resource "azurerm_storage_account" "table_cors" {
  name                     = "tablecorsuniversal"
  resource_group_name      = "rg-test"
  location                 = "eastus"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_account_table_properties" "table_cors" {
  storage_account_id = azurerm_storage_account.table_cors.id

  cors_rule {
    allowed_origins    = ["https://myapp.contoso.com"]
    allowed_methods    = ["GET"]
    allowed_headers    = ["Content-Type"]
    exposed_headers    = ["x-ms-request-id"]
    max_age_in_seconds = 100
  }
}

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

# Queue service settings on the standalone resource with no cors_rule
resource "azurerm_storage_account" "queue_no_cors" {
  name                     = "queuenocorsuniversal"
  resource_group_name      = "rg-test"
  location                 = "eastus"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_account_queue_properties" "queue_no_cors" {
  storage_account_id = azurerm_storage_account.queue_no_cors.id

  logging {
    version               = "1.0"
    delete                = true
    read                  = true
    write                 = true
    retention_policy_days = 7
  }
}

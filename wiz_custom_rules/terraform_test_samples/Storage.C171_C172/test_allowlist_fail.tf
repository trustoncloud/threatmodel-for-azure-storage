# Storage.C172 (authorized_network_bypass) - allowlist - VIOLATING

# Logging and Metrics bypasses not authorized: 2 findings
resource "azurerm_storage_account" "logging_metrics_bypass" {
  name                     = "examplebypassbad"
  resource_group_name      = "example-rg"
  location                 = "eastus"
  account_tier             = "Standard"
  account_replication_type = "LRS"

  network_rules {
    default_action = "Deny"
    bypass         = ["Logging", "Metrics"]
  }
}

# Standalone network rules with an unauthorized Logging bypass: 1 finding
resource "azurerm_storage_account_network_rules" "logging_bypass" {
  storage_account_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/example-rg/providers/Microsoft.Storage/storageAccounts/examplebypasslog"
  default_action     = "Deny"
  bypass             = ["AzureServices", "Logging"]
}

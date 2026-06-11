# Storage.C109 (storage_account_lock_required) - allowlist - VIOLATING

# Required account with NO management lock: 1 finding
resource "azurerm_storage_account" "billing" {
  name                     = "billing-archive"
  resource_group_name      = "rg-test"
  location                 = "eastus"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

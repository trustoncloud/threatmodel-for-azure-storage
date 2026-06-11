# Storage.C109 (storage_account_lock_required) - universal - VIOLATING

# Account with NO management lock: 1 finding
resource "azurerm_storage_account" "unlocked" {
  name                     = "unlocked-acct"
  resource_group_name      = "rg-test"
  location                 = "eastus"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

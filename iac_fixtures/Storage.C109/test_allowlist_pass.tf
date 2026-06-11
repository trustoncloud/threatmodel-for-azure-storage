# Storage.C109 (storage_account_lock_required) - allowlist - COMPLIANT (0 findings)

# Required account WITH a valid management lock
resource "azurerm_storage_account" "prod" {
  name                     = "prod-storage-01"
  resource_group_name      = "rg-test"
  location                 = "eastus"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_management_lock" "prod_lock" {
  name       = "prod-lock"
  scope      = azurerm_storage_account.prod.id
  lock_level = "CanNotDelete"
}

# Non-required account: not enforced, no lock needed
resource "azurerm_storage_account" "scratch" {
  name                     = "scratch-acct"
  resource_group_name      = "rg-test"
  location                 = "eastus"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

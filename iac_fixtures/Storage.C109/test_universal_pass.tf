# Storage.C109 (storage_account_lock_required) - universal - COMPLIANT (0 findings)

# Account WITH a valid management lock (ReadOnly)
resource "azurerm_storage_account" "acct" {
  name                     = "any-acct"
  resource_group_name      = "rg-test"
  location                 = "eastus"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_management_lock" "acct_lock" {
  name       = "acct-lock"
  scope      = azurerm_storage_account.acct.id
  lock_level = "ReadOnly"
}

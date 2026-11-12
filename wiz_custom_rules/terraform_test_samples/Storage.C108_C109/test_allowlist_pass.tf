# Storage.C109 (storage_account_lock_required) - allowlist - COMPLIANT (0 findings)

# Required account WITH a valid management lock
resource "azurerm_storage_account" "prod" {
  name                     = "exampleprodstorage01"
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
  name                     = "examplescratchacct"
  resource_group_name      = "rg-test"
  location                 = "eastus"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# Lock on the resource group the account is declared in, by reference
resource "azurerm_resource_group" "billing_rg" {
  name     = "example-billing-rg"
  location = "eastus"
}

resource "azurerm_storage_account" "billing_in_rg" {
  name                     = "examplebilling"
  resource_group_name      = azurerm_resource_group.billing_rg.name
  location                 = "eastus"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_management_lock" "billing_rg_lock" {
  name       = "billing-rg-lock"
  scope      = azurerm_resource_group.billing_rg.id
  lock_level = "CanNotDelete"
}

# Lock on a resource group read by a data source, account names that group literally
data "azurerm_resource_group" "shared" {
  name = "example-shared-rg"
}

resource "azurerm_storage_account" "billing_in_shared" {
  name                     = "examplebilling"
  resource_group_name      = "Example-Shared-RG"
  location                 = "eastus"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_management_lock" "shared_rg_lock" {
  name       = "shared-rg-lock"
  scope      = data.azurerm_resource_group.shared.id
  lock_level = "ReadOnly"
}

# Lock on the account by its literal ID
resource "azurerm_storage_account" "billing_by_id" {
  name                     = "exampleprodstorage01"
  resource_group_name      = "example-id-rg"
  location                 = "eastus"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_management_lock" "account_id_lock" {
  name       = "account-id-lock"
  scope      = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/example-id-rg/providers/Microsoft.Storage/storageAccounts/exampleprodstorage01"
  lock_level = "CanNotDelete"
}

# Account and lock created with count; the lock references the account by instance index
resource "azurerm_storage_account" "counted" {
  count                    = 1
  name                     = "examplebilling"
  resource_group_name      = "rg-counted"
  location                 = "eastus"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_management_lock" "counted" {
  count      = 1
  name       = "lock-counted"
  scope      = azurerm_storage_account.counted[0].id
  lock_level = "CanNotDelete"
}

# Storage.C109 (storage_account_lock_required) - universal - COMPLIANT (0 findings)

# Account WITH a valid management lock (ReadOnly)
resource "azurerm_storage_account" "acct" {
  name                     = "exampleanyacct"
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

# Lock on the resource group the account is declared in, by reference
resource "azurerm_resource_group" "billing_rg" {
  name     = "example-billing-rg"
  location = "eastus"
}

resource "azurerm_storage_account" "acct_in_rg" {
  name                     = "exampleanyacct"
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

resource "azurerm_storage_account" "acct_in_shared" {
  name                     = "exampleanyacct"
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

# Lock on the current subscription; it covers every account in this file
data "azurerm_subscription" "current" {
}

resource "azurerm_storage_account" "acct_in_subscription" {
  name                     = "exampleanyacct"
  resource_group_name      = "example-other-rg"
  location                 = "eastus"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_management_lock" "subscription_lock" {
  name       = "subscription-lock"
  scope      = data.azurerm_subscription.current.id
  lock_level = "CanNotDelete"
}

# Lock on the account by its literal ID
resource "azurerm_storage_account" "acct_by_id" {
  name                     = "exampleidacct"
  resource_group_name      = "example-id-rg"
  location                 = "eastus"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_management_lock" "account_id_lock" {
  name       = "account-id-lock"
  scope      = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/example-id-rg/providers/Microsoft.Storage/storageAccounts/exampleidacct"
  lock_level = "CanNotDelete"
}

# Storage.C109 (storage_account_lock_required) - universal - VIOLATING

# Account with NO management lock: 1 finding
resource "azurerm_storage_account" "unlocked" {
  name                     = "exampleunlockedacct"
  resource_group_name      = "rg-test"
  location                 = "eastus"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# Lock belongs to an account with a longer local name: 1 finding
resource "azurerm_storage_account" "acct" {
  name                     = "exampleanyacct"
  resource_group_name      = "rg-test"
  location                 = "eastus"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_account" "acct_next" {
  name                     = "exampleanyacct2"
  resource_group_name      = "rg-test"
  location                 = "eastus"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_management_lock" "next_lock" {
  name       = "next-lock"
  scope      = azurerm_storage_account.acct_next.id
  lock_level = "CanNotDelete"
}

# Lock on another resource group than the account's: 1 finding
resource "azurerm_resource_group" "app_rg" {
  name     = "example-app-rg"
  location = "eastus"
}

resource "azurerm_resource_group" "other_rg" {
  name     = "example-other-rg"
  location = "eastus"
}

resource "azurerm_storage_account" "acct_app" {
  name                     = "exampleanyacct"
  resource_group_name      = azurerm_resource_group.app_rg.name
  location                 = "eastus"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_management_lock" "other_rg_lock" {
  name       = "other-rg-lock"
  scope      = azurerm_resource_group.other_rg.id
  lock_level = "CanNotDelete"
}

# Literal resource group ID next to the account's group: 1 finding
resource "azurerm_storage_account" "acct_near_rg" {
  name                     = "exampleanyacct"
  resource_group_name      = "example-near-rg"
  location                 = "eastus"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_management_lock" "near_rg_lock" {
  name       = "near-rg-lock"
  scope      = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/example-near-rg-old"
  lock_level = "CanNotDelete"
}

# Lock on a literal subscription ID, which cannot be tied to the account: 1 finding
resource "azurerm_storage_account" "acct_literal_sub" {
  name                     = "exampleanyacct"
  resource_group_name      = "example-sub-rg"
  location                 = "eastus"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_management_lock" "literal_sub_lock" {
  name       = "literal-sub-lock"
  scope      = "/subscriptions/00000000-0000-0000-0000-000000000000"
  lock_level = "CanNotDelete"
}

# Lock on a subscription data source that names another subscription: 1 finding
data "azurerm_subscription" "other" {
  subscription_id = "11111111-1111-1111-1111-111111111111"
}

resource "azurerm_storage_account" "acct_other_sub" {
  name                     = "exampleanyacct"
  resource_group_name      = "example-sub-rg"
  location                 = "eastus"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_management_lock" "other_sub_lock" {
  name       = "other-sub-lock"
  scope      = data.azurerm_subscription.other.id
  lock_level = "CanNotDelete"
}

# Lock on a literal resource group ID: its subscription cannot be compared with
# the account's, so it is not counted: 1 finding
resource "azurerm_storage_account" "acct_in_literal_rg" {
  name                     = "exampleanyacct"
  resource_group_name      = "example-literal-rg"
  location                 = "eastus"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_management_lock" "literal_rg_lock" {
  name       = "literal-rg-lock"
  scope      = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/example-literal-rg"
  lock_level = "CanNotDelete"
}

# Subscription and resource group locks made through another provider
# configuration, so in another subscription than the accounts: 2 findings
provider "azurerm" {
  alias = "c109_universal_other"
  features {}
}

data "azurerm_subscription" "aliased" {
  provider = azurerm.c109_universal_other
}

resource "azurerm_management_lock" "other_subscription_lock" {
  provider   = azurerm.c109_universal_other
  name       = "other-subscription-lock"
  scope      = data.azurerm_subscription.aliased.id
  lock_level = "CanNotDelete"
}

resource "azurerm_storage_account" "acct_beside_other_subscription" {
  name                     = "exampleanyacct"
  resource_group_name      = "rg-unlocked"
  location                 = "eastus"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

data "azurerm_resource_group" "aliased" {
  provider = azurerm.c109_universal_other
  name     = "example-shared-rg"
}

resource "azurerm_management_lock" "aliased_rg_lock" {
  provider   = azurerm.c109_universal_other
  name       = "other-rg-lock"
  scope      = data.azurerm_resource_group.aliased.id
  lock_level = "CanNotDelete"
}

resource "azurerm_storage_account" "acct_in_same_named_rg" {
  name                     = "exampleanyacct"
  resource_group_name      = data.azurerm_resource_group.aliased.name
  location                 = "eastus"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

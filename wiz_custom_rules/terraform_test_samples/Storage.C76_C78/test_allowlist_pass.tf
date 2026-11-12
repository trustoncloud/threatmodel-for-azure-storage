# This is testing Storage.C78 (authorized_region_detection) - allowlist variant
# Expected outcome: COMPLIANT (0 findings)

# Test case 1: Location in allowlist ("eastus")
resource "azurerm_storage_account" "compliant_c78_allowlist_eastus" {
  name                     = "compliantregallowlist1"
  resource_group_name      = "rg-test"
  location                 = "eastus"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# Test case 2: Location in allowlist ("westeurope")
resource "azurerm_storage_account" "compliant_c78_allowlist_westeurope" {
  name                     = "compliantregallowlist2"
  resource_group_name      = "rg-test"
  location                 = "westeurope"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# Test case 3: display name of an allowed region ("East US")
resource "azurerm_storage_account" "compliant_c78_allowlist_display" {
  name                     = "compliantregallowlist3"
  resource_group_name      = "rg-test"
  location                 = "East US"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# Test case 4: location taken from a resource group declared in this file
resource "azurerm_resource_group" "c78_allowlist_rg" {
  name     = "rg-c78-allowlist"
  location = "West Europe"
}

resource "azurerm_storage_account" "compliant_c78_allowlist_rg" {
  name                     = "compliantregallowlist4"
  resource_group_name      = azurerm_resource_group.c78_allowlist_rg.name
  location                 = azurerm_resource_group.c78_allowlist_rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# Test case 5: location copied from a resource group created with count
resource "azurerm_resource_group" "c78_allowlist_rg_counted" {
  count    = 1
  name     = "rg-c78-allowlist-counted"
  location = "North Europe"
}

resource "azurerm_storage_account" "compliant_c78_allowlist_rg_counted" {
  name                     = "compliantregallowlist5"
  resource_group_name      = azurerm_resource_group.c78_allowlist_rg_counted[0].name
  location                 = azurerm_resource_group.c78_allowlist_rg_counted[0].location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

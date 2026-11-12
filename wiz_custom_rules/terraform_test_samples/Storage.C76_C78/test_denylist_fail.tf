# This is testing Storage.C78 (authorized_region_detection) - denylist variant
# Expected outcome: VIOLATING (findings on .location)

# Test case 1: Location is in denylist ("brazilsouth")
resource "azurerm_storage_account" "violating_c78_denylist" {
  name                     = "violatingregdenylist"
  resource_group_name      = "rg-test"
  location                 = "brazilsouth" # Violating (forbidden)
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# Test case 2: display name of a forbidden region ("Brazil South"): 1 finding
resource "azurerm_storage_account" "violating_c78_denylist_display" {
  name                     = "violatingregdenylist2"
  resource_group_name      = "rg-test"
  location                 = "Brazil South"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# Test case 3: resource group in a forbidden region: 1 finding
resource "azurerm_resource_group" "c78_denylist_rg" {
  name     = "rg-c78-denylist"
  location = "Central India"
}

resource "azurerm_storage_account" "violating_c78_denylist_rg" {
  name                     = "violatingregdenylist3"
  resource_group_name      = azurerm_resource_group.c78_denylist_rg.name
  location                 = azurerm_resource_group.c78_denylist_rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# Test case 4: location from a variable with no default, not resolved: 1 finding
variable "c78_denylist_location" {
  type = string
}

resource "azurerm_storage_account" "violating_c78_denylist_var" {
  name                     = "violatingregdenylist4"
  resource_group_name      = "rg-test"
  location                 = var.c78_denylist_location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

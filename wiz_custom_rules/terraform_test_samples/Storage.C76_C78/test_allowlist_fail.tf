# This is testing Storage.C78 (authorized_region_detection) - allowlist variant
# Expected outcome: VIOLATING (findings on .location)

# Test case 1: Location not in allowlist ("brazilsouth")
resource "azurerm_storage_account" "violating_c78_allowlist" {
  name                     = "violatingregallowlist"
  resource_group_name      = "rg-test"
  location                 = "brazilsouth" # Violating
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# Test case 2: location from a variable with no default, not resolved: 1 finding
variable "c78_allowlist_location" {
  type = string
}

resource "azurerm_storage_account" "violating_c78_allowlist_var" {
  name                     = "violatingregallowlist2"
  resource_group_name      = "rg-test"
  location                 = var.c78_allowlist_location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# Test case 3: resource group in a region outside the allowlist: 1 finding
resource "azurerm_resource_group" "c78_allowlist_rg" {
  name     = "rg-c78-allowlist"
  location = "Brazil South"
}

resource "azurerm_storage_account" "violating_c78_allowlist_rg" {
  name                     = "violatingregallowlist3"
  resource_group_name      = azurerm_resource_group.c78_allowlist_rg.name
  location                 = azurerm_resource_group.c78_allowlist_rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# Test case 4: lookalike of an allowed region ("eastus2"): 1 finding
resource "azurerm_storage_account" "violating_c78_allowlist_lookalike" {
  name                     = "violatingregallowlist4"
  resource_group_name      = "rg-test"
  location                 = "East US 2"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

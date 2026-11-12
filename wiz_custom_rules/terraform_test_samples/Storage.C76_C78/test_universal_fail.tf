# This is testing Storage.C78 (authorized_region_detection) - universal variant
# Expected outcome: VIOLATING (findings on .location)

# Test case 1: Location is not the single required region ("westeurope")
resource "azurerm_storage_account" "violating_c78_universal" {
  name                     = "violatingreguniversal"
  resource_group_name      = "rg-test"
  location                 = "westeurope" # Violating (must be "eastus")
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# Test case 2: lookalike of the required region ("East US 2"): 1 finding
resource "azurerm_storage_account" "violating_c78_universal_lookalike" {
  name                     = "violatingreguniversal2"
  resource_group_name      = "rg-test"
  location                 = "East US 2"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# Test case 3: location from a variable with no default, not resolved: 1 finding
variable "c78_universal_location" {
  type = string
}

resource "azurerm_storage_account" "violating_c78_universal_var" {
  name                     = "violatingreguniversal3"
  resource_group_name      = "rg-test"
  location                 = var.c78_universal_location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

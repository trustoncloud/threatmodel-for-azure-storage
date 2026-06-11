# This is testing Storage.C78 (authorized_region_detection) - universal variant
# Expected outcome: VIOLATING (1 finding on .location)

# Test case 1: Location is not the single required region ("westeurope")
resource "azurerm_storage_account" "violating_c78_universal" {
  name                     = "violatingreguniversal"
  resource_group_name      = "rg-test"
  location                 = "westeurope" # Violating (must be "eastus")
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

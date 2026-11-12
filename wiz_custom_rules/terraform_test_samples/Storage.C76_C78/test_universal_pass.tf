# This is testing Storage.C78 (authorized_region_detection) - universal variant
# Expected outcome: COMPLIANT (0 findings)

# Test case 1: Location is the required single region ("eastus")
resource "azurerm_storage_account" "compliant_c78_universal" {
  name                     = "compliantreguniversal"
  resource_group_name      = "rg-test"
  location                 = "eastus" # Compliant
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# Test case 2: display name of the required region ("East US")
resource "azurerm_resource_group" "c78_universal_rg" {
  name     = "rg-c78-universal"
  location = "East US"
}

resource "azurerm_storage_account" "compliant_c78_universal_rg" {
  name                     = "compliantreguniversal2"
  resource_group_name      = azurerm_resource_group.c78_universal_rg.name
  location                 = azurerm_resource_group.c78_universal_rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

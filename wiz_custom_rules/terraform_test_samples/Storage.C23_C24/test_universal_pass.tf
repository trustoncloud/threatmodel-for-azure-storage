# This is testing Storage.C24 (hns_enabled_detection) - universal variant
# Expected outcome: COMPLIANT (0 findings)

# Test case 1: HNS is disabled (compliant)
resource "azurerm_storage_account" "compliant_c24_disabled" {
  name                     = "standardstorage24"
  resource_group_name      = "rg-test"
  location                 = "eastus"
  account_tier             = "Standard"
  account_replication_type = "LRS"
  is_hns_enabled           = false
}

# Test case 2: HNS is omitted (defaults to false, compliant)
resource "azurerm_storage_account" "compliant_c24_omitted" {
  name                     = "omittedstorage24"
  resource_group_name      = "rg-test"
  location                 = "eastus"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

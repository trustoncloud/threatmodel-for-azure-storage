# This is testing Storage.C24 (hns_enabled_detection) - universal variant
# Expected outcome: VIOLATING (2 findings on .is_hns_enabled)

# Test case 1: HNS is enabled on standard name
resource "azurerm_storage_account" "violating_c24_universal_1" {
  name                     = "unauthorizedlake"
  resource_group_name      = "rg-test"
  location                 = "eastus"
  account_tier             = "Standard"
  account_replication_type = "LRS"
  is_hns_enabled           = true
}

# Test case 2: HNS is enabled on allowlist name (universal variant permits no HNS accounts)
resource "azurerm_storage_account" "violating_c24_universal_2" {
  name                     = "data_lake_prod"
  resource_group_name      = "rg-test"
  location                 = "eastus"
  account_tier             = "Standard"
  account_replication_type = "LRS"
  is_hns_enabled           = true
}

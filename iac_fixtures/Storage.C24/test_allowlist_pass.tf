# This is testing Storage.C24 (hns_enabled_detection) - allowlist variant
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

# Test case 2: HNS is enabled, name in allowlist ("data_lake_prod")
resource "azurerm_storage_account" "compliant_c24_allowlist_1" {
  name                     = "data_lake_prod"
  resource_group_name      = "rg-test"
  location                 = "eastus"
  account_tier             = "Standard"
  account_replication_type = "LRS"
  is_hns_enabled           = true
}

# Test case 3: HNS is enabled, name in allowlist ("analytics_storage_01")
resource "azurerm_storage_account" "compliant_c24_allowlist_2" {
  name                     = "analytics_storage_01"
  resource_group_name      = "rg-test"
  location                 = "eastus"
  account_tier             = "Standard"
  account_replication_type = "LRS"
  is_hns_enabled           = true
}

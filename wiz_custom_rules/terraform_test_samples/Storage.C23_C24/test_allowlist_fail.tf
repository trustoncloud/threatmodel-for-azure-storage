# This is testing Storage.C24 (hns_enabled_detection) - allowlist variant
# Expected outcome: VIOLATING (1 finding on .is_hns_enabled)

# Test case 1: HNS is enabled, but name is not in allowlist
resource "azurerm_storage_account" "violating_c24_unauthorized" {
  name                     = "unauthorizedlake"
  resource_group_name      = "rg-test"
  location                 = "eastus"
  account_tier             = "Standard"
  account_replication_type = "LRS"
  is_hns_enabled           = true
}

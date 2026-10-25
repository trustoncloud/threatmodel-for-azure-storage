# This is testing Storage.C78 (authorized_region_detection) - denylist variant
# Expected outcome: VIOLATING (1 finding on .location)

# Test case 1: Location is in denylist ("brazilsouth")
resource "azurerm_storage_account" "violating_c78_denylist" {
  name                     = "violatingregdenylist"
  resource_group_name      = "rg-test"
  location                 = "brazilsouth" # Violating (forbidden)
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

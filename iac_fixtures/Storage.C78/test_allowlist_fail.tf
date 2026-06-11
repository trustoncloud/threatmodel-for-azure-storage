# This is testing Storage.C78 (authorized_region_detection) - allowlist variant
# Expected outcome: VIOLATING (1 finding on .location)

# Test case 1: Location not in allowlist ("westus")
resource "azurerm_storage_account" "violating_c78_allowlist" {
  name                     = "violatingregallowlist"
  resource_group_name      = "rg-test"
  location                 = "westus" # Violating
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

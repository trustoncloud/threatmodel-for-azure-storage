# This is testing Storage.C28 (shared_key_access_enabled) - universal variant
# Expected outcome: COMPLIANT (0 findings)

# Test case 1: Shared Key explicitly disabled (compliant for all)
resource "azurerm_storage_account" "compliant_c28_disabled" {
  name                     = "compliantsasdisabled"
  resource_group_name      = "rg-test"
  location                 = "eastus"
  account_tier             = "Standard"
  account_replication_type = "LRS"
  shared_access_key_enabled = false
}

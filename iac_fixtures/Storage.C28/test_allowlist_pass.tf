# This is testing Storage.C28 (shared_key_access_enabled) - allowlist variant
# Expected outcome: COMPLIANT (0 findings)

# Test case 1: Shared Key explicitly disabled (compliant)
resource "azurerm_storage_account" "compliant_c28_disabled" {
  name                     = "compliantsasdisabled"
  resource_group_name      = "rg-test"
  location                 = "eastus"
  account_tier             = "Standard"
  account_replication_type = "LRS"
  shared_access_key_enabled = false
}

# Test case 2: Shared Key enabled, name in allowlist ("backup_storage_prod")
resource "azurerm_storage_account" "compliant_c28_allowlist_1" {
  name                     = "backup_storage_prod"
  resource_group_name      = "rg-test"
  location                 = "eastus"
  account_tier             = "Standard"
  account_replication_type = "LRS"
  shared_access_key_enabled = true
}

# Test case 3: Shared Key omitted (defaults to true), name in allowlist ("legacy_app_share")
resource "azurerm_storage_account" "compliant_c28_allowlist_2" {
  name                     = "legacy_app_share"
  resource_group_name      = "rg-test"
  location                 = "eastus"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# This is testing Storage.C28 (shared_key_access_enabled) - allowlist variant
# Expected outcome: VIOLATING (2 findings: 1 on .shared_access_key_enabled, 1 on resource absence)

# Test case 1: Shared Key explicitly enabled, name not in allowlist
resource "azurerm_storage_account" "violating_c28_explicit" {
  name                     = "unauthorizedsas"
  resource_group_name      = "rg-test"
  location                 = "eastus"
  account_tier             = "Standard"
  account_replication_type = "LRS"
  shared_access_key_enabled = true
}

# Test case 2: Shared Key omitted (defaults to true), name not in allowlist
resource "azurerm_storage_account" "violating_c28_omitted" {
  name                     = "unauthorizedomitted"
  resource_group_name      = "rg-test"
  location                 = "eastus"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

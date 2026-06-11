# This is testing Storage.C28 (shared_key_access_enabled) - universal variant
# Expected outcome: VIOLATING (3 findings: universal permits no exceptions)

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

# Test case 3: Shared Key enabled, name in allowlist (universal flags this too)
resource "azurerm_storage_account" "violating_c28_allowlist_name" {
  name                     = "backup_storage_prod"
  resource_group_name      = "rg-test"
  location                 = "eastus"
  account_tier             = "Standard"
  account_replication_type = "LRS"
  shared_access_key_enabled = true
}

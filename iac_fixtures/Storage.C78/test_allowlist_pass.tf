# This is testing Storage.C78 (authorized_region_detection) - allowlist variant
# Expected outcome: COMPLIANT (0 findings)

# Test case 1: Location in allowlist ("eastus")
resource "azurerm_storage_account" "compliant_c78_allowlist_eastus" {
  name                     = "compliantregallowlist1"
  resource_group_name      = "rg-test"
  location                 = "eastus"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# Test case 2: Location in allowlist ("westeurope")
resource "azurerm_storage_account" "compliant_c78_allowlist_westeurope" {
  name                     = "compliantregallowlist2"
  resource_group_name      = "rg-test"
  location                 = "westeurope"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

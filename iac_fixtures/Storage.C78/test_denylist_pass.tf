# This is testing Storage.C78 (authorized_region_detection) - denylist variant
# Expected outcome: COMPLIANT (0 findings)

# Test case 1: Location not in forbidden list ("eastus")
resource "azurerm_storage_account" "compliant_c78_denylist" {
  name                     = "compliantregdenylist"
  resource_group_name      = "rg-test"
  location                 = "eastus" # Compliant
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

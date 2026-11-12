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

# Test case 2: display name of a region that is not forbidden ("West Europe")
resource "azurerm_storage_account" "compliant_c78_denylist_display" {
  name                     = "compliantregdenylist2"
  resource_group_name      = "rg-test"
  location                 = "West Europe"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# Test case 3: lookalike of a forbidden region is not forbidden ("brazilsoutheast")
resource "azurerm_storage_account" "compliant_c78_denylist_lookalike" {
  name                     = "compliantregdenylist3"
  resource_group_name      = "rg-test"
  location                 = "Brazil Southeast"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

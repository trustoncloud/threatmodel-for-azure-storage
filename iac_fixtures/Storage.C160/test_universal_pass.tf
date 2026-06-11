# This is testing Storage.C160 (datalake_acl_security) - universal variant
# Expected outcome: COMPLIANT (0 findings)

# Test case 1: Data Lake (HNS = true) with Shared Key disabled
resource "azurerm_storage_account" "compliant_c160_universal" {
  name                     = "compliantdatalake"
  resource_group_name      = "rg-test"
  location                 = "eastus"
  account_tier             = "Standard"
  account_replication_type = "LRS"
  is_hns_enabled           = true
  shared_access_key_enabled = false
}

# Test case 2: Out of scope (HNS is false)
resource "azurerm_storage_account" "compliant_c160_non_hns" {
  name                     = "standardnonlake"
  resource_group_name      = "rg-test"
  location                 = "eastus"
  account_tier             = "Standard"
  account_replication_type = "LRS"
  is_hns_enabled           = false
  shared_access_key_enabled = true
}

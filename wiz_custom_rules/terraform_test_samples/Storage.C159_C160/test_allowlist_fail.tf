# This is testing Storage.C160 (datalake_acl_security) - allowlist variant
# Expected outcome: VIOLATING (2 findings: 1 on explicitly enabled SAS, 1 on omitted SAS)

# Test case 1: Data Lake with Shared Key enabled (not in legacy allowlist)
resource "azurerm_storage_account" "violating_c160_sas_enabled" {
  name                     = "violatingdatalakesas"
  resource_group_name      = "rg-test"
  location                 = "eastus"
  account_tier             = "Standard"
  account_replication_type = "LRS"
  is_hns_enabled           = true
  shared_access_key_enabled = true
}

# Test case 2: Data Lake with Shared Key omitted (defaults to true)
resource "azurerm_storage_account" "violating_c160_sas_omitted" {
  name                     = "violatingdatalakeomitted"
  resource_group_name      = "rg-test"
  location                 = "eastus"
  account_tier             = "Standard"
  account_replication_type = "LRS"
  is_hns_enabled           = true
}

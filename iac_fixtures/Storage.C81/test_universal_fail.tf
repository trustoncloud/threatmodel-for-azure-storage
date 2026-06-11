# Storage.C81 (shared_key_auth_detection) - universal - VIOLATING

# Both settings omitted (inherit insecure defaults): 2 findings
resource "azurerm_storage_account" "violating_omitted" {
  name                     = "acct-omitted"
  resource_group_name      = "rg-test"
  location                 = "eastus"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# Shared Key enabled and OAuth explicitly false: 2 findings
resource "azurerm_storage_account" "violating_explicit" {
  name                            = "acct-explicit"
  resource_group_name             = "rg-test"
  location                        = "eastus"
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  shared_access_key_enabled       = true
  default_to_oauth_authentication = false
}

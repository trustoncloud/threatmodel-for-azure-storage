# Storage.C81 (shared_key_auth_detection) - universal - COMPLIANT (0 findings)

# Shared Key disabled AND OAuth default enabled
resource "azurerm_storage_account" "compliant" {
  name                            = "secure-acct"
  resource_group_name             = "rg-test"
  location                        = "eastus"
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  shared_access_key_enabled       = false
  default_to_oauth_authentication = true
}

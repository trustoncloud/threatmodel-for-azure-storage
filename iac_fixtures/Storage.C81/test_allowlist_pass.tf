# Storage.C81 (shared_key_auth_detection) - allowlist - COMPLIANT (0 findings)

# Required account, fully compliant (Shared Key disabled + OAuth default)
resource "azurerm_storage_account" "compliant_required" {
  name                            = "finance-archive"
  resource_group_name             = "rg-test"
  location                        = "eastus"
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  shared_access_key_enabled       = false
  default_to_oauth_authentication = true
}

# Non-required account: not enforced even though it is insecure
resource "azurerm_storage_account" "non_required" {
  name                      = "random-public-acct"
  resource_group_name       = "rg-test"
  location                  = "eastus"
  account_tier              = "Standard"
  account_replication_type  = "LRS"
  shared_access_key_enabled = true
}

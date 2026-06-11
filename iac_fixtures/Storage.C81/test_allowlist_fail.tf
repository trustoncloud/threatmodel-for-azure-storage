# Storage.C81 (shared_key_auth_detection) - allowlist - VIOLATING

# Required account, both settings omitted (inherit insecure defaults):
# 2 findings (shared_access_key_enabled + default_to_oauth_authentication)
resource "azurerm_storage_account" "violating_required_omitted" {
  name                     = "audit-logs"
  resource_group_name      = "rg-test"
  location                 = "eastus"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# Required account, Shared Key explicitly enabled and OAuth omitted: 2 findings
resource "azurerm_storage_account" "violating_required_explicit" {
  name                      = "prod-customer-data"
  resource_group_name       = "rg-test"
  location                  = "eastus"
  account_tier              = "Standard"
  account_replication_type  = "LRS"
  shared_access_key_enabled = true
}

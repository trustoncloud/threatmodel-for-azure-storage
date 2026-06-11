# Storage.C146 (container_immutability_required) - allowlist - COMPLIANT (0 findings)

# Required container WITH an immutability policy
resource "azurerm_storage_container" "finance" {
  name               = "finance-archive"
  storage_account_id = azurerm_storage_account.sa.id
}

resource "azurerm_storage_container_immutability_policy" "finance_imm" {
  storage_container_resource_manager_id = azurerm_storage_container.finance.resource_manager_id
  immutability_period_in_days           = 30
}

# Non-required container: not enforced, no policy needed
resource "azurerm_storage_container" "scratch" {
  name               = "scratch"
  storage_account_id = azurerm_storage_account.sa.id
}

# Storage.C146 (container_immutability_required) - allowlist - VIOLATING

# Required container with NO immutability policy: 1 finding
resource "azurerm_storage_container" "audit" {
  name               = "audit-logs"
  storage_account_id = azurerm_storage_account.sa.id
}

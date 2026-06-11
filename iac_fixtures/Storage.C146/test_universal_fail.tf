# Storage.C146 (container_immutability_required) - universal - VIOLATING

# Container with NO immutability policy: 1 finding
resource "azurerm_storage_container" "mutable" {
  name               = "mutable"
  storage_account_id = azurerm_storage_account.sa.id
}

# Storage.C146 (container_immutability_required) - universal - COMPLIANT (0 findings)

# Container WITH an immutability policy
resource "azurerm_storage_container" "data" {
  name               = "data"
  storage_account_id = azurerm_storage_account.sa.id
}

resource "azurerm_storage_container_immutability_policy" "data_imm" {
  storage_container_resource_manager_id = azurerm_storage_container.data.resource_manager_id
  immutability_period_in_days           = 90
}

# Storage.C146 (container_immutability_required) - universal - COMPLIANT (0 findings)

# Container WITH an immutability policy
resource "azurerm_storage_account" "sa" {
  name                     = "examplestorageacct"
  resource_group_name      = "rg-test"
  location                 = "eastus"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "data" {
  name               = "data"
  storage_account_id = azurerm_storage_account.sa.id
}

resource "azurerm_storage_container_immutability_policy" "data_imm" {
  storage_container_resource_manager_id = azurerm_storage_container.data.id
  immutability_period_in_days           = 90
}

# Container and policy created with count; the policy references the container by instance index
resource "azurerm_storage_container" "counted" {
  count              = 1
  name               = "counted"
  storage_account_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Storage/storageAccounts/examplecounted"
}

resource "azurerm_storage_container_immutability_policy" "counted" {
  count                                 = 1
  storage_container_resource_manager_id = azurerm_storage_container.counted[0].id
  immutability_period_in_days           = 30
}

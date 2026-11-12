# Storage.C146 (container_immutability_required) - universal - VIOLATING

# Container with NO immutability policy: 1 finding
resource "azurerm_storage_account" "sa" {
  name                     = "examplestorageacct"
  resource_group_name      = "rg-test"
  location                 = "eastus"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "mutable" {
  name               = "mutable"
  storage_account_id = azurerm_storage_account.sa.id
}

# Container whose only policy belongs to a container with a longer local name: 1 finding
resource "azurerm_storage_container" "logs" {
  name               = "logs"
  storage_account_id = azurerm_storage_account.sa.id
}

resource "azurerm_storage_container" "logs_old" {
  name               = "logsold"
  storage_account_id = azurerm_storage_account.sa.id
}

resource "azurerm_storage_container_immutability_policy" "logs_old_imm" {
  storage_container_resource_manager_id = azurerm_storage_container.logs_old.id
  immutability_period_in_days           = 30
}

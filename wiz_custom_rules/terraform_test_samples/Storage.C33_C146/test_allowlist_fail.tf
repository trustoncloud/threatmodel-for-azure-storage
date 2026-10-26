# Storage.C146 (container_immutability_required) - allowlist - VIOLATING

# Required container with NO immutability policy: 1 finding
resource "azurerm_storage_account" "sa" {
  name                     = "examplestorageacct"
  resource_group_name      = "rg-test"
  location                 = "eastus"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "audit" {
  name               = "exampleauditlogs"
  storage_account_id = azurerm_storage_account.sa.id
}

# Storage.C152 (authorized_replication_destination) - allowlist - COMPLIANT

resource "azurerm_storage_account" "replica" {
  name                     = "examplereplicadest"
  resource_group_name      = "example-rg"
  location                 = "westus"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# Destination referenced through the account declared above
resource "azurerm_storage_object_replication" "to_authorized_by_reference" {
  source_storage_account_id      = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/example-rg/providers/Microsoft.Storage/storageAccounts/examplereplicasrc"
  destination_storage_account_id = azurerm_storage_account.replica.id

  rules {
    source_container_name      = "example-source"
    destination_container_name = "example-destination"
  }
}

# Destination given as a literal resource ID
resource "azurerm_storage_object_replication" "to_authorized_by_id" {
  source_storage_account_id      = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/example-rg/providers/Microsoft.Storage/storageAccounts/examplereplicasrc"
  destination_storage_account_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/example-rg/providers/Microsoft.Storage/storageAccounts/ExampleReplicaDest"

  rules {
    source_container_name      = "example-source"
    destination_container_name = "example-destination"
  }

  rules {
    source_container_name      = "example-source-2"
    destination_container_name = "example-destination-2"
  }
}

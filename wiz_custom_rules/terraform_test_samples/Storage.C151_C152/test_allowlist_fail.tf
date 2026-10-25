# Storage.C152 (authorized_replication_destination) - allowlist - VIOLATING

resource "azurerm_storage_account" "unknown_replica" {
  name                     = "exampleunknownreplica"
  resource_group_name      = "example-rg"
  location                 = "westus"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# Destination referenced through an unauthorized account: 1 finding
resource "azurerm_storage_object_replication" "to_unauthorized_by_reference" {
  source_storage_account_id      = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/example-rg/providers/Microsoft.Storage/storageAccounts/examplereplicasrc"
  destination_storage_account_id = azurerm_storage_account.unknown_replica.id

  rules {
    source_container_name      = "example-source"
    destination_container_name = "example-destination"
  }
}

# Destination given as a literal ID of an unauthorized account: 1 finding
resource "azurerm_storage_object_replication" "to_unauthorized_by_id" {
  source_storage_account_id      = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/example-rg/providers/Microsoft.Storage/storageAccounts/examplereplicasrc"
  destination_storage_account_id = "/subscriptions/11111111-1111-1111-1111-111111111111/resourceGroups/other-rg/providers/Microsoft.Storage/storageAccounts/exampleexternalcopy"

  rules {
    source_container_name      = "example-source"
    destination_container_name = "example-destination"
  }
}

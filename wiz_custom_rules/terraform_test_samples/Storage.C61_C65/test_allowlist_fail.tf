# Storage.C65 (authorized_customer_managed_key) - allowlist - VIOLATING

# Inline customer_managed_key naming a key from another vault: 1 finding
resource "azurerm_storage_account" "unauthorized_cmk" {
  name                     = "examplecmkbad"
  resource_group_name      = "example-rg"
  location                 = "eastus"
  account_tier             = "Standard"
  account_replication_type = "LRS"

  identity {
    type         = "UserAssigned"
    identity_ids = ["/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/example-rg/providers/Microsoft.ManagedIdentity/userAssignedIdentities/example-identity"]
  }

  customer_managed_key {
    key_vault_key_id          = "https://unknownvault.vault.azure.net/keys/examplestoragekey"
    user_assigned_identity_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/example-rg/providers/Microsoft.ManagedIdentity/userAssignedIdentities/example-identity"
  }
}

# Standalone resource naming an unauthorized key ID: 1 finding
resource "azurerm_storage_account_customer_managed_key" "unauthorized_by_id" {
  storage_account_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/example-rg/providers/Microsoft.Storage/storageAccounts/examplecmkbyid"
  key_vault_key_id   = "https://examplevault.vault.azure.net/keys/unknownkey"
}

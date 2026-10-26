# Storage.C65 (authorized_customer_managed_key) - allowlist - COMPLIANT

# Inline customer_managed_key naming a version of the authorized key
resource "azurerm_storage_account" "authorized_cmk" {
  name                     = "examplecmkok"
  resource_group_name      = "example-rg"
  location                 = "eastus"
  account_tier             = "Standard"
  account_replication_type = "LRS"

  identity {
    type         = "UserAssigned"
    identity_ids = ["/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/example-rg/providers/Microsoft.ManagedIdentity/userAssignedIdentities/example-identity"]
  }

  customer_managed_key {
    key_vault_key_id          = "https://examplevault.vault.azure.net/keys/examplestoragekey/0123456789abcdef0123456789abcdef"
    user_assigned_identity_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/example-rg/providers/Microsoft.ManagedIdentity/userAssignedIdentities/example-identity"
  }
}

# Standalone resource naming the authorized key by its versionless ID
resource "azurerm_storage_account_customer_managed_key" "authorized_by_id" {
  storage_account_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/example-rg/providers/Microsoft.Storage/storageAccounts/examplecmkbyid"
  key_vault_key_id   = "https://examplevault.vault.azure.net/keys/examplestoragekey"
}

# Microsoft-managed keys: nothing to judge
resource "azurerm_storage_account" "microsoft_managed" {
  name                     = "examplemskey"
  resource_group_name      = "example-rg"
  location                 = "eastus"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

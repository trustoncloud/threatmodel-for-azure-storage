# Storage.C134 (authorized_account_kind) - allowlist - VIOLATING

# Premium block blob kind not in the allowlist: 1 finding
resource "azurerm_storage_account" "unauthorized_block_blob" {
  name                     = "exampleblockblob"
  resource_group_name      = "example-rg"
  location                 = "eastus"
  account_kind             = "BlockBlobStorage"
  account_tier             = "Premium"
  account_replication_type = "LRS"
}

# Legacy general-purpose v1 kind: 1 finding
resource "azurerm_storage_account" "unauthorized_v1" {
  name                     = "examplegpv1"
  resource_group_name      = "example-rg"
  location                 = "eastus"
  account_kind             = "Storage"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

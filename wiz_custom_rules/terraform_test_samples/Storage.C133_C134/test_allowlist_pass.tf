# Storage.C134 (authorized_account_kind) - allowlist - COMPLIANT

resource "azurerm_storage_account" "general_purpose_v2" {
  name                     = "examplegpv2"
  resource_group_name      = "example-rg"
  location                 = "eastus"
  account_kind             = "StorageV2"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# account_kind omitted: defaults to StorageV2
resource "azurerm_storage_account" "kind_default" {
  name                     = "examplekinddefault"
  resource_group_name      = "example-rg"
  location                 = "eastus"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

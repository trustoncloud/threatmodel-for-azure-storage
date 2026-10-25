# Storage.C169 (authorized_virtual_network_rules) - allowlist - VIOLATING

# Inline network rules naming an unauthorized subnet: 1 finding
resource "azurerm_storage_account" "unauthorized_subnet" {
  name                     = "examplevnetbad"
  resource_group_name      = "example-rg"
  location                 = "eastus"
  account_tier             = "Standard"
  account_replication_type = "LRS"

  network_rules {
    default_action = "Deny"
    virtual_network_subnet_ids = [
      "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/example-rg/providers/Microsoft.Network/virtualNetworks/example-vnet/subnets/example-app-subnet",
      "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/example-rg/providers/Microsoft.Network/virtualNetworks/example-vnet/subnets/example-unknown-subnet",
    ]
  }
}

# Standalone network rules resource naming an unauthorized subnet: 1 finding
resource "azurerm_storage_account_network_rules" "unauthorized_subnet" {
  storage_account_id         = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/example-rg/providers/Microsoft.Storage/storageAccounts/examplenetrulesbad"
  default_action             = "Deny"
  virtual_network_subnet_ids = ["/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/example-rg/providers/Microsoft.Network/virtualNetworks/example-vnet/subnets/example-unknown-subnet"]
}

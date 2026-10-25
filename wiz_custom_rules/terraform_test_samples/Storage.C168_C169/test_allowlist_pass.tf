# Storage.C169 (authorized_virtual_network_rules) - allowlist - COMPLIANT

# Inline network rules naming the authorized subnet
resource "azurerm_storage_account" "authorized_subnet" {
  name                     = "examplevnetok"
  resource_group_name      = "example-rg"
  location                 = "eastus"
  account_tier             = "Standard"
  account_replication_type = "LRS"

  network_rules {
    default_action             = "Deny"
    virtual_network_subnet_ids = ["/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/example-rg/providers/Microsoft.Network/virtualNetworks/example-vnet/subnets/example-app-subnet"]
  }
}

# Standalone network rules resource naming the authorized subnet
resource "azurerm_storage_account_network_rules" "authorized_subnet" {
  storage_account_id         = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/example-rg/providers/Microsoft.Storage/storageAccounts/examplenetrulesok"
  default_action             = "Deny"
  virtual_network_subnet_ids = ["/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/example-rg/providers/Microsoft.Network/virtualNetworks/example-vnet/subnets/example-app-subnet"]
}

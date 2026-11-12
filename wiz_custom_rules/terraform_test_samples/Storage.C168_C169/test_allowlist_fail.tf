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

# Subnet given by a reference to a subnet resource: not verifiable from this source, 1 finding
resource "azurerm_virtual_network" "app" {
  name                = "example-vnet"
  location            = "eastus"
  resource_group_name = "example-rg"
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "app" {
  name                 = "example-app-subnet"
  resource_group_name  = "example-rg"
  virtual_network_name = azurerm_virtual_network.app.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_storage_account" "subnet_reference" {
  name                     = "examplevnetref"
  resource_group_name      = "example-rg"
  location                 = "eastus"
  account_tier             = "Standard"
  account_replication_type = "LRS"

  network_rules {
    default_action             = "Deny"
    virtual_network_subnet_ids = [azurerm_subnet.app.id]
  }
}

# Subnet list from a variable with no default: not verifiable from this source, 1 finding
variable "c169_subnet_ids" {
  type = list(string)
}

resource "azurerm_storage_account_network_rules" "subnet_variable" {
  storage_account_id         = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/example-rg/providers/Microsoft.Storage/storageAccounts/examplevnetvar"
  default_action             = "Deny"
  virtual_network_subnet_ids = var.c169_subnet_ids
}

# Subnet next door to the authorized one, and the authorized name in another resource group: 2 findings
resource "azurerm_storage_account_network_rules" "subnet_lookalikes" {
  storage_account_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/example-rg/providers/Microsoft.Storage/storageAccounts/examplevnetlook"
  default_action     = "Deny"
  virtual_network_subnet_ids = [
    "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/example-rg/providers/Microsoft.Network/virtualNetworks/example-vnet/subnets/example-app-subnet2",
    "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/example-rg-2/providers/Microsoft.Network/virtualNetworks/example-vnet/subnets/example-app-subnet",
  ]
}

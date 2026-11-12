# Storage.C40 (private_endpoint_authorized) - allowlist - COMPLIANT (0 findings)

resource "azurerm_storage_account" "sa" {
  name                     = "examplestorageacct"
  resource_group_name      = "rg-test"
  location                 = "eastus"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_resource_group" "net" {
  name     = "net-rg"
  location = "eastus"
}

resource "azurerm_private_dns_zone" "blob" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = "net-rg"
}

# Storage endpoint, automatic connection, authorized zone declared here
resource "azurerm_private_endpoint" "pe" {
  name                = "pe-prod-01"
  location            = "eastus"
  resource_group_name = "net-rg"
  subnet_id           = "/subscriptions/123/resourceGroups/net-rg/providers/Microsoft.Network/virtualNetworks/vnet/subnets/pe-subnet"

  private_service_connection {
    name                           = "psc"
    private_connection_resource_id = azurerm_storage_account.sa.id
    is_manual_connection           = false
    subresource_names              = ["blob"]
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [azurerm_private_dns_zone.blob.id]
  }
}

# Storage endpoint with a literal storage account target and the literal ID of
# an authorized zone
resource "azurerm_private_endpoint" "pe_literal_zone" {
  name                = "PE-PROD-02"
  location            = "eastus"
  resource_group_name = azurerm_resource_group.net.name
  subnet_id           = "/subscriptions/123/resourceGroups/net-rg/providers/Microsoft.Network/virtualNetworks/vnet/subnets/pe-subnet"

  private_service_connection {
    name                           = "psc"
    private_connection_resource_id = "/subscriptions/123/resourceGroups/rg-test/providers/Microsoft.Storage/storageAccounts/examplestorageacct"
    is_manual_connection           = false
    subresource_names              = ["file"]
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = ["/subscriptions/123/resourceGroups/net-rg/providers/Microsoft.Network/privateDnsZones/privatelink.file.core.windows.net"]
  }
}

# Private endpoint of another service: not reviewed by this rule
resource "azurerm_private_endpoint" "pe_key_vault" {
  name                = "pe-vault"
  location            = "eastus"
  resource_group_name = "net-rg"
  subnet_id           = "/subscriptions/123/resourceGroups/net-rg/providers/Microsoft.Network/virtualNetworks/vnet/subnets/pe-subnet"

  private_service_connection {
    name                           = "psc"
    private_connection_resource_id = "/subscriptions/123/resourceGroups/sec-rg/providers/Microsoft.KeyVault/vaults/example-vault"
    is_manual_connection           = true
    request_message                = "please approve"
    subresource_names              = ["vault"]
  }
}

# Storage endpoint created with count; zone and account referenced by instance index
variable "c40_enable_pe" {
  type    = bool
  default = true
}

resource "azurerm_storage_account" "sa_counted" {
  count                    = var.c40_enable_pe ? 1 : 0
  name                     = "examplecountedacct"
  resource_group_name      = "rg-test"
  location                 = "eastus"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_private_dns_zone" "blob_counted" {
  count               = var.c40_enable_pe ? 1 : 0
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = "net-rg"
}

resource "azurerm_private_endpoint" "pe_counted" {
  count               = var.c40_enable_pe ? 1 : 0
  name                = "pe-prod-01"
  location            = "eastus"
  resource_group_name = "net-rg"
  subnet_id           = "/subscriptions/123/resourceGroups/net-rg/providers/Microsoft.Network/virtualNetworks/vnet/subnets/pe-subnet"

  private_service_connection {
    name                           = "psc"
    private_connection_resource_id = azurerm_storage_account.sa_counted[0].id
    is_manual_connection           = false
    subresource_names              = ["blob"]
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [azurerm_private_dns_zone.blob_counted[0].id]
  }
}

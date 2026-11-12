# Storage.C40 (private_endpoint_authorized) - universal - VIOLATING (4 findings)

# Storage private endpoint with NO private_dns_zone_group: 1 finding
resource "azurerm_storage_account" "sa" {
  name                     = "examplestorageacct"
  resource_group_name      = "rg-test"
  location                 = "eastus"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_private_endpoint" "pe_no_dns" {
  name                = "pe-no-dns"
  location            = "eastus"
  resource_group_name = "rg-test"
  subnet_id           = "/subscriptions/123/resourceGroups/net-rg/providers/Microsoft.Network/virtualNetworks/vnet/subnets/pe-subnet"

  private_service_connection {
    name                           = "psc"
    private_connection_resource_id = azurerm_storage_account.sa.id
    is_manual_connection           = false
    subresource_names              = ["blob"]
  }
}

resource "azurerm_private_dns_zone" "blob" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = "rg-test"
}

# Manual connection request (boolean), approved later by the account owner: 1 finding
resource "azurerm_private_endpoint" "pe_manual" {
  name                = "pe-manual"
  location            = "eastus"
  resource_group_name = "rg-test"
  subnet_id           = "/subscriptions/123/resourceGroups/net-rg/providers/Microsoft.Network/virtualNetworks/vnet/subnets/pe-subnet"

  private_service_connection {
    name                           = "psc"
    private_connection_resource_id = azurerm_storage_account.sa.id
    is_manual_connection           = true
    request_message                = "please approve"
    subresource_names              = ["blob"]
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [azurerm_private_dns_zone.blob.id]
  }
}

# Manual connection (string) to a literal storage account ID: 1 finding
resource "azurerm_private_endpoint" "pe_manual_string" {
  name                = "pe-manual-string"
  location            = "eastus"
  resource_group_name = "rg-test"
  subnet_id           = "/subscriptions/123/resourceGroups/net-rg/providers/Microsoft.Network/virtualNetworks/vnet/subnets/pe-subnet"

  private_service_connection {
    name                           = "psc"
    private_connection_resource_id = "/subscriptions/456/resourceGroups/other-rg/providers/Microsoft.Storage/storageAccounts/otheraccount"
    is_manual_connection           = "true"
    request_message                = "please approve"
    subresource_names              = ["blob"]
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [azurerm_private_dns_zone.blob.id]
  }
}

# Literal storage account target with a sub-resource in upper case, no zone group: 1 finding
resource "azurerm_private_endpoint" "pe_literal_no_dns" {
  name                = "pe-literal-no-dns"
  location            = "eastus"
  resource_group_name = "rg-test"
  subnet_id           = "/subscriptions/123/resourceGroups/net-rg/providers/Microsoft.Network/virtualNetworks/vnet/subnets/pe-subnet"

  private_service_connection {
    name                           = "psc"
    private_connection_resource_id = "/subscriptions/123/resourceGroups/rg-test/providers/Microsoft.Storage/storageAccounts/examplestorageacct"
    is_manual_connection           = false
    subresource_names              = ["Blob"]
  }
}

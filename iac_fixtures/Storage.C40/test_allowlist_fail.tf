# Storage.C40 (private_endpoint_authorized) - allowlist - VIOLATING

resource "azurerm_private_dns_zone" "custom" {
  name                = "privatelink.custom.example.net"
  resource_group_name = "rg-test"
}

# References a private DNS zone that is not in the authorized set: 1 finding
resource "azurerm_private_endpoint" "pe_unauth_zone" {
  name                = "pe-unauth-zone"
  location            = "eastus"
  resource_group_name = "rg-test"
  subnet_id           = "/subscriptions/123/resourceGroups/net-rg/providers/Microsoft.Network/virtualNetworks/vnet/subnets/pe-subnet"

  private_service_connection {
    name                           = "psc"
    private_connection_resource_id = azurerm_storage_account.sa.id
    is_manual_connection           = false
    subresource_names              = ["blob"]
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [azurerm_private_dns_zone.custom.id]
  }
}

# No private_dns_zone_group at all: 1 finding
resource "azurerm_private_endpoint" "pe_no_zone" {
  name                = "pe-no-zone"
  location            = "eastus"
  resource_group_name = "rg-test"
  subnet_id           = "/subscriptions/123/resourceGroups/net-rg/providers/Microsoft.Network/virtualNetworks/vnet/subnets/pe-subnet"

  private_service_connection {
    name                           = "psc"
    private_connection_resource_id = azurerm_storage_account.sa.id
    is_manual_connection           = false
    subresource_names              = ["file"]
  }
}

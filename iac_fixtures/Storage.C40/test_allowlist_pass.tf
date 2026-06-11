# Storage.C40 (private_endpoint_authorized) - allowlist - COMPLIANT (0 findings)

resource "azurerm_private_dns_zone" "blob" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = "rg-test"
}

# Storage private endpoint integrated with an authorized private DNS zone
resource "azurerm_private_endpoint" "pe" {
  name                = "pe-storage"
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
    private_dns_zone_ids = [azurerm_private_dns_zone.blob.id]
  }
}

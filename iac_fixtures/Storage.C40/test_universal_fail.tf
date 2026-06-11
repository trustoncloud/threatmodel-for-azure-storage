# Storage.C40 (private_endpoint_authorized) - universal - VIOLATING

# Storage private endpoint with NO private_dns_zone_group: 1 finding
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

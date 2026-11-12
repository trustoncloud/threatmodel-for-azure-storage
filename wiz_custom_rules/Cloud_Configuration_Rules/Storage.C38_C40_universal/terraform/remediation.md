Give every storage private endpoint a private DNS zone group:

```hcl
resource "azurerm_private_endpoint" "example" {
  private_service_connection {
    name                           = "storage"
    private_connection_resource_id = azurerm_storage_account.example.id
    is_manual_connection           = false
    subresource_names              = ["blob"]
  }

  private_dns_zone_group {
    name                 = "storage"
    private_dns_zone_ids = [azurerm_private_dns_zone.blob.id]
  }
}
```

A connection with `is_manual_connection = true` is a request: it stays Pending until the owner of the storage account approves or rejects it, so it is reported for review. A manual request is not unauthorized in itself, and the source scan does not see whether it was approved; the deployed connection state is checked by the cloud rule. Use an automatic connection when the identity that deploys the endpoint can approve connections on the account.

## References

- [azurerm_private_endpoint (hashicorp/azurerm 5.10.0)](https://registry.terraform.io/providers/hashicorp/azurerm/5.10.0/docs/resources/private_endpoint)
- [Access to a private link resource using approval workflow (Microsoft Learn)](https://learn.microsoft.com/en-us/azure/private-link/private-endpoint-overview#access-to-a-private-link-resource-using-approval-workflow)

Checked 2026-10-23 against hashicorp/azurerm 4.81.0 and 5.10.0: resources, arguments and links.

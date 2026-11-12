A storage private endpoint must link to a private DNS zone in `authorized_dns_zones`. Give it an authorized zone:

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

An endpoint counts as a storage endpoint when its target is a storage account (a reference to one, or its literal resource ID), or when its target is not resolved by this source scan and it asks for a storage sub-resource. A private DNS zone counts when it is declared in the same configuration or given as a literal zone ID.

A connection with `is_manual_connection = true` is a request: it stays Pending until the owner of the storage account approves or rejects it, so it is reported for review. A manual request is not unauthorized in itself, and the source scan does not see whether it was approved; the deployed connection state is checked by the cloud rule. Use an automatic connection when the identity that deploys the endpoint can approve connections on the account.

This rule does not check which endpoints are authorized: the source does not show the subscription an endpoint is created in, so its identity cannot be established from the Terraform source. The cloud rule checks every connection on the account against the full endpoint resource IDs in `authorized_endpoints`.

## References

- [azurerm_private_endpoint (hashicorp/azurerm 5.10.0)](https://registry.terraform.io/providers/hashicorp/azurerm/5.10.0/docs/resources/private_endpoint)
- [Access to a private link resource using approval workflow (Microsoft Learn)](https://learn.microsoft.com/en-us/azure/private-link/private-endpoint-overview#access-to-a-private-link-resource-using-approval-workflow)

Checked 2026-10-23 against hashicorp/azurerm 4.81.0 and 5.10.0: resources, arguments and links.

Link the storage private endpoint to an authorized private DNS zone, or add the zone to `authorized_dns_zones` once approved:

```hcl
resource "azurerm_private_endpoint" "example" {
  private_dns_zone_group {
    name                 = "storage"
    private_dns_zone_ids = [azurerm_private_dns_zone.blob.id]
  }
}
```

## References

- [azurerm_private_endpoint (hashicorp/azurerm 5.10.0)](https://registry.terraform.io/providers/hashicorp/azurerm/5.10.0/docs/resources/private_endpoint)

Checked 2026-10-23 against hashicorp/azurerm 4.81.0 and 5.10.0: resources, arguments and links.

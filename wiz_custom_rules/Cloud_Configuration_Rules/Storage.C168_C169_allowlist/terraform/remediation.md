List only authorized subnets in `virtual_network_subnet_ids`, or add a subnet to `authorized_subnet_ids` once approved:

```hcl
resource "azurerm_storage_account" "example" {
  network_rules {
    default_action             = "Deny"
    virtual_network_subnet_ids = [azurerm_subnet.app.id]
  }
}
```

## References

- [azurerm_storage_account (hashicorp/azurerm 5.10.0)](https://registry.terraform.io/providers/hashicorp/azurerm/5.10.0/docs/resources/storage_account)

Checked 2026-10-23 against hashicorp/azurerm 4.81.0 and 5.10.0: resources, arguments and links.

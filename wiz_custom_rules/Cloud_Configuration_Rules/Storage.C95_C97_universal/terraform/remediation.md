Declare no `cors_rule` blocks in `blob_properties`, `queue_properties` or `share_properties`:

```hcl
resource "azurerm_storage_account" "example" {
  blob_properties {
    versioning_enabled = true
  }
}
```

## References

- [azurerm_storage_account (hashicorp/azurerm 5.10.0)](https://registry.terraform.io/providers/hashicorp/azurerm/5.10.0/docs/resources/storage_account)

Checked 2026-10-23 against hashicorp/azurerm 4.81.0 and 5.10.0: resources, arguments and links.

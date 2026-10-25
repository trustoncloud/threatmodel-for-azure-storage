Declare only authorized stored access policies, with authorized permissions listed in the order the provider documents:

```hcl
resource "azurerm_storage_share" "example" {
  acl {
    id = "examplereadonly"

    access_policy {
      permissions = "rl"
    }
  }
}
```

Or add the identifier and permissions to the rule's configuration once approved.

## References

- [azurerm_storage_share (hashicorp/azurerm 5.10.0)](https://registry.terraform.io/providers/hashicorp/azurerm/5.10.0/docs/resources/storage_share)

Checked 2026-10-23 against hashicorp/azurerm 4.81.0 and 5.10.0: resources, arguments and links.

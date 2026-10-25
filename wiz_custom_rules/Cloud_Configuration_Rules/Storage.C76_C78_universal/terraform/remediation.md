Declare the account in `required_region`:

```hcl
resource "azurerm_storage_account" "example" {
  location = "eastus"
}
```

Changing `location` makes Terraform replace the account, so move its data first.

## References

- [azurerm_storage_account (hashicorp/azurerm 5.10.0)](https://registry.terraform.io/providers/hashicorp/azurerm/5.10.0/docs/resources/storage_account)

Checked 2026-10-23 against hashicorp/azurerm 4.81.0 and 5.10.0: resources, arguments and links.

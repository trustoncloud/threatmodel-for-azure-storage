Turn Shared Key off and default to Entra ID on every account:

```hcl
resource "azurerm_storage_account" "example" {
  shared_access_key_enabled       = false
  default_to_oauth_authentication = true
}
```

`shared_access_key_enabled` defaults to true, so set it explicitly.

## References

- [azurerm_storage_account (hashicorp/azurerm 5.10.0)](https://registry.terraform.io/providers/hashicorp/azurerm/5.10.0/docs/resources/storage_account)

Checked 2026-10-23 against hashicorp/azurerm 4.81.0 and 5.10.0: resources, arguments and links.

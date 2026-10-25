Declare a lock on every account in `required_lock_accounts`, in the same file as the account:

```hcl
resource "azurerm_management_lock" "example" {
  name       = "storage-delete-lock"
  scope      = azurerm_storage_account.example.id
  lock_level = "CanNotDelete"
}
```

## References

- [azurerm_management_lock (hashicorp/azurerm 5.10.0)](https://registry.terraform.io/providers/hashicorp/azurerm/5.10.0/docs/resources/management_lock)

Checked 2026-10-23 against hashicorp/azurerm 4.81.0 and 5.10.0: resources, arguments and links.

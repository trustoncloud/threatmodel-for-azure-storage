Declare a lock on every account, in the same file as the account:

```hcl
resource "azurerm_management_lock" "example" {
  name       = "storage-delete-lock"
  scope      = azurerm_storage_account.example.id
  lock_level = "CanNotDelete"
}
```

A lock on the account's resource group or on the current subscription also protects the account and is accepted when it is declared in the same file as the account:

- `scope` references the resource group (`azurerm_resource_group.<name>.id` or `data.azurerm_resource_group.<name>.id`), and the account's `resource_group_name` references that group's `name` or matches it.
- `scope` is `data.azurerm_subscription.<name>.id` from a data source that sets no `subscription_id`.

The account, the lock and the resource group or subscription it names must use the same provider configuration (the same `provider` alias, or none), so that they sit in the same subscription.

A lock on a literal subscription or resource group ID is not accepted, because the account's subscription comes from the provider configuration and cannot be compared with it. A lock declared in another file or outside the scanned configuration, for example by a platform team, is not seen, so the account is reported.

## References

- [azurerm_management_lock (hashicorp/azurerm 5.10.0)](https://registry.terraform.io/providers/hashicorp/azurerm/5.10.0/docs/resources/management_lock)

Checked 2026-10-23 against hashicorp/azurerm 4.81.0 and 5.10.0: resources, arguments and links.

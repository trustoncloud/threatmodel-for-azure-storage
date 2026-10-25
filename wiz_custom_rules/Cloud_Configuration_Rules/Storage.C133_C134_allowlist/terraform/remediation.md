Declare an authorized `account_kind`; it defaults to StorageV2. Or add the kind to `authorized_account_kinds` once approved:

```hcl
resource "azurerm_storage_account" "example" {
  account_kind = "StorageV2"
}
```

Changing `account_kind` to anything other than an upgrade to StorageV2 makes Terraform replace the account.

## References

- [azurerm_storage_account (hashicorp/azurerm 5.10.0)](https://registry.terraform.io/providers/hashicorp/azurerm/5.10.0/docs/resources/storage_account)

Checked 2026-10-23 against hashicorp/azurerm 4.81.0 and 5.10.0: resources, arguments and links.

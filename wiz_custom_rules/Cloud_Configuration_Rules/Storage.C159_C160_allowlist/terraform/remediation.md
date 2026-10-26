Turn Shared Key off on accounts with the hierarchical namespace, or add the account to `authorized_legacy_datalakes` once approved:

```hcl
resource "azurerm_storage_account" "example" {
  is_hns_enabled            = true
  shared_access_key_enabled = false
}
```

## References

- [azurerm_storage_account (hashicorp/azurerm 5.10.0)](https://registry.terraform.io/providers/hashicorp/azurerm/5.10.0/docs/resources/storage_account)

Checked 2026-10-23 against hashicorp/azurerm 4.81.0 and 5.10.0: resources, arguments and links.

Name an authorized key, by its versionless or versioned key ID, in either the account's `customer_managed_key` block or a standalone `azurerm_storage_account_customer_managed_key`, not both:

```hcl
resource "azurerm_storage_account_customer_managed_key" "example" {
  storage_account_id = azurerm_storage_account.example.id
  key_vault_key_id   = "https://examplevault.vault.azure.net/keys/examplestoragekey"
}
```

Or add the key's versionless URL to `authorized_key_urls` once approved.

## References

- [azurerm_storage_account_customer_managed_key (hashicorp/azurerm 5.10.0)](https://registry.terraform.io/providers/hashicorp/azurerm/5.10.0/docs/resources/storage_account_customer_managed_key)

Checked 2026-10-23 against hashicorp/azurerm 4.81.0 and 5.10.0: resources, arguments and links.

Replicate only to an authorized destination account, or add the account to `authorized_replication_destination_accounts` once approved:

```hcl
resource "azurerm_storage_object_replication" "example" {
  source_storage_account_id      = azurerm_storage_account.source.id
  destination_storage_account_id = azurerm_storage_account.replica.id

  rules {
    source_container_name      = "source"
    destination_container_name = "replica"
  }
}
```

## References

- [azurerm_storage_object_replication (hashicorp/azurerm 5.10.0)](https://registry.terraform.io/providers/hashicorp/azurerm/5.10.0/docs/resources/storage_object_replication)

Checked 2026-10-23 against hashicorp/azurerm 4.81.0 and 5.10.0: resources, arguments and links.

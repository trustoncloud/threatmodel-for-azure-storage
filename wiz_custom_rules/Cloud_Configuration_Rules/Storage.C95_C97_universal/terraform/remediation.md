Declare no `cors_rule` blocks: not in `blob_properties` or `share_properties` on the account, not in `azurerm_storage_account_queue_properties` or `azurerm_storage_account_table_properties`, and, on azurerm 4.x, not in an inline `queue_properties` block:

```hcl
resource "azurerm_storage_account" "example" {
  blob_properties {
    versioning_enabled = true
  }
}

resource "azurerm_storage_account_queue_properties" "example" {
  storage_account_id = azurerm_storage_account.example.id

  logging {
    version               = "1.0"
    delete                = true
    read                  = true
    write                 = true
    retention_policy_days = 7
  }
}
```

## References

- [azurerm_storage_account (hashicorp/azurerm 5.10.0)](https://registry.terraform.io/providers/hashicorp/azurerm/5.10.0/docs/resources/storage_account)
- [azurerm_storage_account_queue_properties (hashicorp/azurerm 5.10.0)](https://registry.terraform.io/providers/hashicorp/azurerm/5.10.0/docs/resources/storage_account_queue_properties)
- [azurerm_storage_account_table_properties (hashicorp/azurerm 5.10.0)](https://registry.terraform.io/providers/hashicorp/azurerm/5.10.0/docs/resources/storage_account_table_properties)

Checked 2026-10-23 against hashicorp/azurerm 4.81.0 and 5.10.0: resources, arguments and links.

Declare a SAS expiration policy no longer than `max_sas_expiration_period`, with action Block, on every account that allows Shared Key:

```hcl
resource "azurerm_storage_account" "example" {
  sas_policy {
    expiration_period = "1.00:00:00"
    expiration_action = "Block"
  }
}
```

`expiration_action` defaults to `Log`, so set it explicitly. An account with `shared_access_key_enabled = false` needs no SAS policy.

## References

- [azurerm_storage_account (hashicorp/azurerm 5.10.0)](https://registry.terraform.io/providers/hashicorp/azurerm/5.10.0/docs/resources/storage_account)

Checked 2026-10-23 against hashicorp/azurerm 4.81.0 and 5.10.0: resources, arguments and links.

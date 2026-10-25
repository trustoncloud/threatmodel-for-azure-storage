List only authorized values in `bypass`, or add a value to `authorized_network_bypass` once approved:

```hcl
resource "azurerm_storage_account" "example" {
  network_rules {
    default_action = "Deny"
    bypass         = ["AzureServices"]
  }
}
```

## References

- [azurerm_storage_account (hashicorp/azurerm 5.10.0)](https://registry.terraform.io/providers/hashicorp/azurerm/5.10.0/docs/resources/storage_account)

Checked 2026-10-23 against hashicorp/azurerm 4.81.0 and 5.10.0: resources, arguments and links.

Deny by default and list only authorized ranges in `ip_rules`, or add a range to `authorized_ips` once approved:

```hcl
resource "azurerm_storage_account" "example" {
  network_rules {
    default_action = "Deny"
    ip_rules       = ["203.0.113.0/24"]
  }
}
```

A storage account with neither a `network_rules` block nor an `azurerm_storage_account_network_rules` resource in the same configuration allows every network and is reported. The standalone resource counts when its `storage_account_id` references the account or gives the account's literal resource ID.

## References

- [azurerm_storage_account (hashicorp/azurerm 5.10.0)](https://registry.terraform.io/providers/hashicorp/azurerm/5.10.0/docs/resources/storage_account)

Checked 2026-10-23 against hashicorp/azurerm 4.81.0 and 5.10.0: resources, arguments and links.

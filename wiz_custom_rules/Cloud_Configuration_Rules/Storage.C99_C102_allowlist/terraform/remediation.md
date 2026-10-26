List only SMB 3.0 and later in `versions`, or add the account to `allowed_smb21_accounts` once approved:

```hcl
resource "azurerm_storage_account" "example" {
  share_properties {
    smb {
      versions = ["SMB3.0", "SMB3.1.1"]
    }
  }
}
```

## References

- [azurerm_storage_account (hashicorp/azurerm 5.10.0)](https://registry.terraform.io/providers/hashicorp/azurerm/5.10.0/docs/resources/storage_account)

Checked 2026-10-23 against hashicorp/azurerm 4.81.0 and 5.10.0: resources, arguments and links.

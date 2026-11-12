List only SMB 3.0 and later in `versions`, or add the account to `allowed_smb21_accounts` once approved. An omitted `versions` list, `smb` block or `share_properties` block keeps Azure's default, which allows SMB 2.1; accounts of kind `BlockBlobStorage` and `BlobStorage` have no file shares and are not checked. An NFS share (`enabled_protocol = "NFS"`) is allowed only on an account in `allowed_smb21_accounts`: set its `storage_account_id` to a reference to that account in the same configuration, or to the account's literal resource ID. A share whose account or protocol the source scan cannot resolve is reported.

```hcl
resource "azurerm_storage_account" "example" {
  share_properties {
    smb {
      versions = ["SMB3.0", "SMB3.1.1"]
    }
  }
}

resource "azurerm_storage_share" "example" {
  enabled_protocol = "SMB"
}
```

A variable that declares a default is checked at that default, because the scan reads the Terraform source. Terraform can deploy a value passed in its place, and a passing scan does not cover that value.

## References

- [azurerm_storage_account (hashicorp/azurerm 5.10.0)](https://registry.terraform.io/providers/hashicorp/azurerm/5.10.0/docs/resources/storage_account)
- [azurerm_storage_share (hashicorp/azurerm 5.10.0)](https://registry.terraform.io/providers/hashicorp/azurerm/5.10.0/docs/resources/storage_share)

Checked 2026-10-23 against hashicorp/azurerm 4.81.0 and 5.10.0: resources, arguments and links.

List only permitted versions in `versions`. An omitted `versions` list, `smb` block or `share_properties` block keeps Azure's default, which allows every version; accounts of kind `BlockBlobStorage` and `BlobStorage` have no file shares and are not checked. Give file shares a protocol that is not in `forbidden_share_protocols`. A value the source scan cannot resolve is reported.

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

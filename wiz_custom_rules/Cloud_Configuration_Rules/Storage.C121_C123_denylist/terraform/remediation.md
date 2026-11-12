List no method from `forbidden_methods`. An omitted list, `smb` block or `share_properties` block keeps Azure's default, which allows every option; accounts of kind `BlockBlobStorage` and `BlobStorage` have no file shares and are not checked. A value the source scan cannot resolve is reported.

```hcl
resource "azurerm_storage_account" "example" {
  share_properties {
    smb {
      kerberos_ticket_encryption_type = ["AES-256"]
      channel_encryption_type         = ["AES-256-GCM"]
    }
  }
}
```

A variable that declares a default is checked at that default, because the scan reads the Terraform source. Terraform can deploy a value passed in its place, and a passing scan does not cover that value.

## References

- [azurerm_storage_account (hashicorp/azurerm 5.10.0)](https://registry.terraform.io/providers/hashicorp/azurerm/5.10.0/docs/resources/storage_account)

Checked 2026-10-23 against hashicorp/azurerm 4.81.0 and 5.10.0: resources, arguments and links.

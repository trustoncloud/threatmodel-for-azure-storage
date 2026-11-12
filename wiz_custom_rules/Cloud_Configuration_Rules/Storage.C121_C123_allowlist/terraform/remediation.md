On every account in `required_secure_shares`, list only the Kerberos and channel encryption values of the configured policy. An omitted list, `smb` block or `share_properties` block keeps Azure's default, which allows every supported value; accounts of kind `BlockBlobStorage` and `BlobStorage` have no file shares and are not checked. A value the source scan cannot resolve is reported.

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

The default policy allows AES-256 Kerberos tickets and AES-256-GCM channel encryption only. Azure also supports AES-128-CCM and AES-128-GCM channel encryption; this policy excludes them by choice. Clients that cannot negotiate AES-256-GCM, such as older SMB clients, cannot connect when it is the only channel encryption allowed, so check your clients before applying it, and change `required_kerberos` and `required_channel` if your policy differs.

## References

- [azurerm_storage_account (hashicorp/azurerm 5.10.0)](https://registry.terraform.io/providers/hashicorp/azurerm/5.10.0/docs/resources/storage_account)
- [SMB File Shares in Azure Files](https://learn.microsoft.com/en-us/azure/storage/files/files-smb-protocol)

Checked 2026-10-23 against hashicorp/azurerm 4.81.0 and 5.10.0: resources, arguments and links.

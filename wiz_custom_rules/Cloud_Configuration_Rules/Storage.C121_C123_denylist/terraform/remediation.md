List no method from `forbidden_methods`:

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

## References

- [azurerm_storage_account (hashicorp/azurerm 5.10.0)](https://registry.terraform.io/providers/hashicorp/azurerm/5.10.0/docs/resources/storage_account)

Checked 2026-10-23 against hashicorp/azurerm 4.81.0 and 5.10.0: resources, arguments and links.

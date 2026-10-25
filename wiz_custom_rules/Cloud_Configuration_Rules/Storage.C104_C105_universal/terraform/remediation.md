Turn on malware scanning on upload for each account, or declare the Defender for Storage plan with the OnUploadMalwareScanning extension in the same file:

```hcl
resource "azurerm_security_center_storage_defender" "example" {
  storage_account_id                 = azurerm_storage_account.example.id
  malware_scanning_on_upload_enabled = true
}
```

Deleting `azurerm_security_center_subscription_pricing` resets the plan to Free for the whole subscription.

## References

- [azurerm_security_center_storage_defender (hashicorp/azurerm 5.10.0)](https://registry.terraform.io/providers/hashicorp/azurerm/5.10.0/docs/resources/security_center_storage_defender)

Checked 2026-10-23 against hashicorp/azurerm 4.81.0 and 5.10.0: resources, arguments and links.

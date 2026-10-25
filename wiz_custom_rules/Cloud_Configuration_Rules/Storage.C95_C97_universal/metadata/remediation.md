# Remediation

The account in the finding has CORS rules, which this environment does not allow. Clear them on every service:

```bash
az storage account blob-service-properties cors-rule clear --account-name <account-name> --resource-group <resource-group>
az storage cors clear --services fqt --account-name <account-name>
```

Replace `<account-name>` and `<resource-group>` with the storage account in the finding.

## References

- [az storage account blob-service-properties cors-rule clear](https://learn.microsoft.com/en-us/cli/azure/storage/account/blob-service-properties/cors-rule?view=azure-cli-latest#az-storage-account-blob-service-properties-cors-rule-clear)
- [az storage cors clear](https://learn.microsoft.com/en-us/cli/azure/storage/cors?view=azure-cli-latest#az-storage-cors-clear)
- [Cross-Origin Resource Sharing (CORS) support for Azure Storage](https://learn.microsoft.com/en-us/rest/api/storageservices/cross-origin-resource-sharing--cors--support-for-the-azure-storage-services)

Checked 2026-10-23 with Azure CLI 2.91.0: command syntax, flags and links.

## Testing Compliance
Create a storage account with untrusted CORS settings; it should be detected.

# Remediation

A CORS rule on the account in the finding uses an origin, method, header or max age outside the authorized values. Clear the rules and add back only authorized ones:

```bash
az storage account blob-service-properties cors-rule clear --account-name <account-name> --resource-group <resource-group>
az storage cors clear --services fqt --account-name <account-name>
```

If the values are approved, add them to `allowed_origins`, `allowed_methods`, `allowed_headers`, `allowed_exposed_headers` or `max_authorized_age` in the rule's configuration instead. Replace `<account-name>` and `<resource-group>` with the storage account in the finding.

## References

- [az storage account blob-service-properties cors-rule clear](https://learn.microsoft.com/en-us/cli/azure/storage/account/blob-service-properties/cors-rule?view=azure-cli-latest#az-storage-account-blob-service-properties-cors-rule-clear)
- [az storage cors clear](https://learn.microsoft.com/en-us/cli/azure/storage/cors?view=azure-cli-latest#az-storage-cors-clear)
- [Cross-Origin Resource Sharing (CORS) support for Azure Storage](https://learn.microsoft.com/en-us/rest/api/storageservices/cross-origin-resource-sharing--cors--support-for-the-azure-storage-services)

Checked 2026-10-23 with Azure CLI 2.91.0: command syntax, flags and links.

## Testing Compliance
Create a storage account with untrusted CORS settings; it should be detected.

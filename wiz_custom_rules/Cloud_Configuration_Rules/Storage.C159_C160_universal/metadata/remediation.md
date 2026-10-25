# Remediation

The account in the finding has the hierarchical namespace enabled and allows Shared Key, which bypasses the access control lists on its containers. Move clients to Microsoft Entra ID, then turn Shared Key off:

```bash
az storage account update --name <account-name> --resource-group <resource-group> --allow-shared-key-access false
```

Replace `<account-name>` and `<resource-group>` with the storage account in the finding.

## References

- [az storage account update](https://learn.microsoft.com/en-us/cli/azure/storage/account?view=azure-cli-latest#az-storage-account-update)
- [Access control lists (ACLs) in Azure Data Lake Storage - Azure Storage](https://learn.microsoft.com/en-us/azure/storage/blobs/data-lake-storage-access-control)

Checked 2026-10-23 with Azure CLI 2.91.0: command syntax, flags and links.

## Testing Compliance
Enable Shared Key authorization (allowSharedKeyAccess = true) on an HNS-enabled storage account, or disable hierarchical namespace (isHnsEnabled = false) on a storage account; it should be detected.

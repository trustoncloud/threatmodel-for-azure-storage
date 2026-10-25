# Remediation

The account in the finding allows an SMB version listed in `forbidden_versions`. Allow only permitted versions:

```bash
az storage account file-service-properties update --account-name <account-name> --resource-group <resource-group> --versions "SMB3.0;SMB3.1.1"
```

Replace `<account-name>` and `<resource-group>` with the storage account in the finding.

## References

- [az storage account file-service-properties update](https://learn.microsoft.com/en-us/cli/azure/storage/account/file-service-properties?view=azure-cli-latest#az-storage-account-file-service-properties-update)
- [SMB File Shares in Azure Files](https://learn.microsoft.com/en-us/azure/storage/files/files-smb-protocol)

Checked 2026-10-23 with Azure CLI 2.91.0: command syntax, flags and links.

## Testing Compliance
Modify an existing file share that does not require NFS/SMB 2.1 to use NFS/SMB 2.1; it should be detected.

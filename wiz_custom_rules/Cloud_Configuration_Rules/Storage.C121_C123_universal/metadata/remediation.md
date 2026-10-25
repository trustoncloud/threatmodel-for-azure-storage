# Remediation

The account in the finding allows weak SMB Kerberos or channel encryption, or leaves both at Azure's default, which allows every option. Allow only the strong values:

```bash
az storage account file-service-properties update --account-name <account-name> --resource-group <resource-group> --kerb-ticket-encryption AES-256 --channel-encryption AES-256-GCM
```

Replace `<account-name>` and `<resource-group>` with the storage account in the finding.

## References

- [az storage account file-service-properties update](https://learn.microsoft.com/en-us/cli/azure/storage/account/file-service-properties?view=azure-cli-latest#az-storage-account-file-service-properties-update)
- [SMB File Shares in Azure Files](https://learn.microsoft.com/en-us/azure/storage/files/files-smb-protocol)

Checked 2026-10-23 with Azure CLI 2.91.0: command syntax, flags and links.

## Testing Compliance
Modify a required file share's security protocol settings; it should be detected.

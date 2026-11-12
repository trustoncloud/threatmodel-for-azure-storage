# Remediation

The account in the finding allows SMB Kerberos or channel encryption values outside the configured policy, or leaves them at Azure's default, which allows every supported value. Allow only the policy values:

```bash
az storage account file-service-properties update --account-name <account-name> --resource-group <resource-group> --kerb-ticket-encryption AES-256 --channel-encryption AES-256-GCM
```

Replace `<account-name>` and `<resource-group>` with the storage account in the finding.

The default policy allows AES-256 Kerberos tickets and AES-256-GCM channel encryption only. Azure also supports AES-128-CCM and AES-128-GCM channel encryption; this policy excludes them by choice. Clients that cannot negotiate AES-256-GCM, such as older SMB clients, cannot connect when it is the only channel encryption allowed, so check your clients before applying it, and change `required_kerberos` and `required_channel` if your policy differs.

## References

- [az storage account file-service-properties update](https://learn.microsoft.com/en-us/cli/azure/storage/account/file-service-properties?view=azure-cli-latest#az-storage-account-file-service-properties-update)
- [SMB File Shares in Azure Files](https://learn.microsoft.com/en-us/azure/storage/files/files-smb-protocol)

Checked 2026-10-23 with Azure CLI 2.91.0: command syntax, flags and links.

## Testing Compliance
Modify a required file share's security protocol settings; it should be detected.

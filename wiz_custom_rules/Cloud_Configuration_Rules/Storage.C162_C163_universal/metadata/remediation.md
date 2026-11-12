# Remediation

The account in the finding accepts SFTP sign-ins from local users. Turn SFTP off:

```bash
az storage account update --name <account-name> --resource-group <resource-group> --enable-sftp false
```

Where a local user remains, it signs in with an SSH key only:

```bash
az storage account local-user update --account-name <account-name> --resource-group <resource-group> --name <local-user-name> --has-ssh-password false
```

Replace `<account-name>` and `<resource-group>` with the storage account in the finding, and `<local-user-name>` with the local user.

Local users, their permissions and their sign-in methods are not part of the storage account data this rule reads, so the rule cannot report a local user, a permission it holds or a password sign-in. Review them on each account where SFTP stays on:

```bash
az storage account local-user list --account-name <account-name> --resource-group <resource-group>
```

## References

- [az storage account update](https://learn.microsoft.com/en-us/cli/azure/storage/account?view=azure-cli-latest#az-storage-account-update)
- [az storage account local-user update](https://learn.microsoft.com/en-us/cli/azure/storage/account/local-user?view=azure-cli-latest#az-storage-account-local-user-update)
- [az storage account local-user list](https://learn.microsoft.com/en-us/cli/azure/storage/account/local-user?view=azure-cli-latest#az-storage-account-local-user-list)
- [Enable or Disable SFTP in Azure Blob Storage - Azure Storage](https://learn.microsoft.com/en-us/azure/storage/blobs/secure-file-transfer-protocol-support-how-to)

Checked 2026-10-23 with Azure CLI 2.91.0: command syntax, flags and links. Behaviour verified in a lab on 2026-10-23.

## Testing Compliance
Enable local users in a hierarchical namespace with SFTP, where local users are not authorized; it should be detected.

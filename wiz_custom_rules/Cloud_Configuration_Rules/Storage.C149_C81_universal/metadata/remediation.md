# Remediation

The account in the finding allows Shared Key or does not default to Microsoft Entra ID (OAuth) in the portal. Turning Shared Key off rejects every request signed with an account key, including SAS tokens other than user delegation SAS, so move clients to Microsoft Entra ID first. Then:

```bash
az storage account update --name <account-name> --resource-group <resource-group> --allow-shared-key-access false
az resource update --ids <account-id> --set properties.defaultToOAuthAuthentication=true
```

Replace `<account-name>` and `<resource-group>` with the storage account in the finding, and `<account-id>` with its resource ID.

## References

- [az storage account update](https://learn.microsoft.com/en-us/cli/azure/storage/account?view=azure-cli-latest#az-storage-account-update)
- [az resource update](https://learn.microsoft.com/en-us/cli/azure/resource?view=azure-cli-latest#az-resource-update)
- [Prevent authorization with Shared Key - Azure Storage](https://learn.microsoft.com/en-us/azure/storage/common/shared-key-authorization-prevent)

Checked 2026-10-23 with Azure CLI 2.91.0: command syntax, flags and links. Behaviour verified in a lab on 2026-10-23.

## Testing Compliance
Configure a storage account with allowSharedKeyAccess enabled and/or defaultToOAuthAuthentication disabled; it should be detected.

# Remediation

The account in the finding is required to use Microsoft Entra ID only, but it allows Shared Key or does not default to Entra ID (OAuth) in the portal. Turning Shared Key off rejects every request signed with an account key, including SAS tokens other than user delegation SAS, so move clients to Microsoft Entra ID first. Then:

```bash
az storage account update --name <account-name> --resource-group <resource-group> --allow-shared-key-access false
az resource update --ids <account-id> --set properties.defaultToOAuthAuthentication=true
```

The account list is `required_secure_accounts` in the rule's configuration. Replace `<account-name>` and `<resource-group>` with the storage account in the finding, and `<account-id>` with its resource ID.

Requiring Microsoft Entra ID as the portal default is controlled by `require_oauth_default` in the rule's configuration (default `true`). The portal default only chooses how the portal authorizes data access; it does not turn Shared Key off. Setting `require_oauth_default` to `false` drops only the portal default check: Shared Key must still be disabled.

## References

- [az storage account update](https://learn.microsoft.com/en-us/cli/azure/storage/account?view=azure-cli-latest#az-storage-account-update)
- [az resource update](https://learn.microsoft.com/en-us/cli/azure/resource?view=azure-cli-latest#az-resource-update)
- [Prevent authorization with Shared Key - Azure Storage](https://learn.microsoft.com/en-us/azure/storage/common/shared-key-authorization-prevent)
- [Default to Microsoft Entra authorization in the Azure portal](https://learn.microsoft.com/en-us/azure/storage/blobs/authorize-data-operations-portal#default-to-microsoft-entra-authorization-in-the-azure-portal)

Checked 2026-10-23 with Azure CLI 2.91.0: command syntax, flags and links. Behaviour verified in a lab on 2026-10-23.

## Testing Compliance
Configure a storage account with allowSharedKeyAccess enabled and/or defaultToOAuthAuthentication disabled; it should be detected.

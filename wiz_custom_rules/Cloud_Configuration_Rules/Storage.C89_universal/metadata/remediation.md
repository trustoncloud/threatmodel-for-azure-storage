# Remediation

The account in the finding allows Shared Key and has no key expiration policy, a policy longer than the approved maximum, or an access key older than its policy. Set the policy, then rotate each overdue key, updating the clients that use it:

```bash
az storage account update --name <account-name> --resource-group <resource-group> --key-exp-days 90
az storage account keys renew --account-name <account-name> --resource-group <resource-group> --key key1
az storage account keys renew --account-name <account-name> --resource-group <resource-group> --key key2
```

Match the period to `max_key_expiration_days` in the rule's configuration. Where no client needs the keys, turning Shared Key off removes them from use:

```bash
az storage account update --name <account-name> --resource-group <resource-group> --allow-shared-key-access false
```

Replace `<account-name>` and `<resource-group>` with the storage account in the finding.

## References

- [az storage account update](https://learn.microsoft.com/en-us/cli/azure/storage/account?view=azure-cli-latest#az-storage-account-update)
- [az storage account keys renew](https://learn.microsoft.com/en-us/cli/azure/storage/account/keys?view=azure-cli-latest#az-storage-account-keys-renew)
- [Manage account access keys - Azure Storage](https://learn.microsoft.com/en-us/azure/storage/common/storage-account-keys-manage)

Checked 2026-10-23 with Azure CLI 2.91.0: command syntax, flags and links. Behaviour verified in a lab on 2026-10-23.

## Testing Compliance
Configure or use a storage account key or Shared Key authorization path outside authorized use, key rotation, or Shared Key authorization requirements; it should be detected.

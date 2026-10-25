# Remediation

An object replication policy on the account in the finding copies blobs to a destination account that is not authorized. Find the policy and delete it:

```bash
az storage account or-policy list --account-name <account-name> --resource-group <resource-group>
az storage account or-policy delete --account-name <account-name> --resource-group <resource-group> --policy-id <policy-id>
```

If the destination is approved, add its account name to `authorized_replication_destination_accounts` in the rule's configuration instead. Replace `<account-name>` and `<resource-group>` with the storage account in the finding, and `<policy-id>` with the policy's ID.

## References

- [az storage account or-policy list](https://learn.microsoft.com/en-us/cli/azure/storage/account/or-policy?view=azure-cli-latest#az-storage-account-or-policy-list)
- [az storage account or-policy delete](https://learn.microsoft.com/en-us/cli/azure/storage/account/or-policy?view=azure-cli-latest#az-storage-account-or-policy-delete)
- [Configure object replication - Azure Storage](https://learn.microsoft.com/en-us/azure/storage/blobs/object-replication-configure)

Checked 2026-10-23 with Azure CLI 2.91.0: command syntax, flags and links.

## Testing Compliance
Add a replication policy with an unauthorized destination storage account or source container; it should be detected.

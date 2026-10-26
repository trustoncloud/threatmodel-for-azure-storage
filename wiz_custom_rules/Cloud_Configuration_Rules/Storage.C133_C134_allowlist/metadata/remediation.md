# Remediation

The account in the finding is a kind that is not authorized. A general-purpose v1 or Blob storage account upgrades in place to general-purpose v2, which cannot be undone:

```bash
az storage account update --name <account-name> --resource-group <resource-group> --set kind=StorageV2 --access-tier Hot
```

A premium BlockBlobStorage or FileStorage account cannot change kind. Create a replacement account with the approved setting, copy the data across (AzCopy or object replication), point consumers at it, then delete the old account:

```bash
az storage account create --name <new-account-name> --resource-group <resource-group> --location <location> --kind StorageV2
az storage account delete --name <account-name> --resource-group <resource-group> --yes
```

If the kind is approved, add it to `authorized_account_kinds` in the rule's configuration instead. Replace `<account-name>` and `<resource-group>` with the storage account in the finding, `<new-account-name>` with the replacement's name and `<location>` with its region.

## References

- [az storage account update](https://learn.microsoft.com/en-us/cli/azure/storage/account?view=azure-cli-latest#az-storage-account-update)
- [az storage account create](https://learn.microsoft.com/en-us/cli/azure/storage/account?view=azure-cli-latest#az-storage-account-create)
- [az storage account delete](https://learn.microsoft.com/en-us/cli/azure/storage/account?view=azure-cli-latest#az-storage-account-delete)
- [Storage Account Overview - Azure Storage](https://learn.microsoft.com/en-us/azure/storage/common/storage-account-overview)
- [Upgrade to a general-purpose v2 storage account - Azure Storage](https://learn.microsoft.com/en-us/azure/storage/common/storage-account-upgrade)

Checked 2026-10-23 with Azure CLI 2.91.0: command syntax, flags and links.

## Testing Compliance
Create or modify a storage account with an unauthorized account type; it should be detected.

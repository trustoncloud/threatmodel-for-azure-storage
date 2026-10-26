# Remediation

The account in the finding is not in the required region. A location cannot be changed.

Create a replacement account with the approved setting, copy the data across (AzCopy or object replication), point consumers at it, then delete the old account:

```bash
az storage account create --name <new-account-name> --resource-group <resource-group> --location <location> --kind StorageV2
az storage account delete --name <account-name> --resource-group <resource-group> --yes
```

Replace `<account-name>` and `<resource-group>` with the storage account in the finding, `<new-account-name>` with the replacement's name and `<location>` with the required region.

## References

- [az storage account create](https://learn.microsoft.com/en-us/cli/azure/storage/account?view=azure-cli-latest#az-storage-account-create)
- [az storage account delete](https://learn.microsoft.com/en-us/cli/azure/storage/account?view=azure-cli-latest#az-storage-account-delete)
- [Data redundancy - Azure Storage](https://learn.microsoft.com/en-us/azure/storage/common/storage-redundancy)
- [Relocate Azure Storage Account to another region - Azure Resource Manager](https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/relocation/relocation-storage-account)

Checked 2026-10-23 with Azure CLI 2.91.0: command syntax, flags and links.

## Testing Compliance
Create a storage account with an unauthorized region; it should be detected.

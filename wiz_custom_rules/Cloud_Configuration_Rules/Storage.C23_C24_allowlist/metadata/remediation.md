# Remediation

The account in the finding has the hierarchical namespace (Data Lake Storage) enabled but is not authorized for it. The namespace cannot be turned off once enabled.

Create a replacement account with the approved setting, copy the data across (AzCopy or object replication), point consumers at it, then delete the old account:

```bash
az storage account create --name <new-account-name> --resource-group <resource-group> --location <location> --kind StorageV2 --hns false
az storage account delete --name <account-name> --resource-group <resource-group> --yes
```

If the account is approved to use the hierarchical namespace, add its name to `allowed_hns_accounts` in the rule's configuration instead. Replace `<account-name>` and `<resource-group>` with the storage account in the finding, `<new-account-name>` with the replacement's name and `<location>` with its region.

## References

- [az storage account create](https://learn.microsoft.com/en-us/cli/azure/storage/account?view=azure-cli-latest#az-storage-account-create)
- [az storage account delete](https://learn.microsoft.com/en-us/cli/azure/storage/account?view=azure-cli-latest#az-storage-account-delete)
- [Azure Data Lake Storage hierarchical namespace - Azure Storage](https://learn.microsoft.com/en-us/azure/storage/blobs/data-lake-storage-namespace)

Checked 2026-10-23 with Azure CLI 2.91.0: command syntax, flags and links.

## Testing Compliance
Create a non-required storage account with the hierarchical namespace (HNS) option enabled; it should be detected.

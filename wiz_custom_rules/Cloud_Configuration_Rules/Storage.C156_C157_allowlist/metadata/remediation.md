# Remediation

A stored access policy on a file share or table in the account in the finding has an identifier or permissions that are not authorized. Delete it, or narrow its permissions:

```bash
az storage share policy delete --account-name <account-name> --share-name <share-name> --name <policy-name>
az storage table policy delete --account-name <account-name> --table-name <table-name> --name <policy-name>
az storage share policy update --account-name <account-name> --share-name <share-name> --name <policy-name> --permissions rl
```

Deleting or changing a policy invalidates the SAS tokens issued under it. If the policy is approved, add its identifier to `authorized_access_policy_ids` and its permissions to `authorized_access_policy_permissions` in the rule's configuration instead. Replace `<account-name>` with the storage account in the finding, `<share-name>` or `<table-name>` with the share or table, and `<policy-name>` with the policy's identifier.

## References

- [az storage share policy delete](https://learn.microsoft.com/en-us/cli/azure/storage/share/policy?view=azure-cli-latest#az-storage-share-policy-delete)
- [az storage table policy delete](https://learn.microsoft.com/en-us/cli/azure/storage/table/policy?view=azure-cli-latest#az-storage-table-policy-delete)
- [az storage share policy update](https://learn.microsoft.com/en-us/cli/azure/storage/share/policy?view=azure-cli-latest#az-storage-share-policy-update)
- [Define a stored access policy - Azure Storage](https://learn.microsoft.com/en-us/rest/api/storageservices/define-stored-access-policy)

Checked 2026-10-23 with Azure CLI 2.91.0: command syntax, flags and links.

## Testing Compliance
Modify an existing stored access policy or its permissions outside authorized values; it should be detected.

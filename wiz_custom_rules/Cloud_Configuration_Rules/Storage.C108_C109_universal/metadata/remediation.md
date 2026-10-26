# Remediation

The account in the finding has no resource lock. Add a delete lock:

```bash
az lock create --name <lock-name> --lock-type CanNotDelete --resource-group <resource-group> --resource <account-name> --resource-type Microsoft.Storage/storageAccounts
```

Creating a lock needs the Owner or User Access Administrator role. Replace `<account-name>` and `<resource-group>` with the storage account in the finding, and `<lock-name>` with a name for the lock.

## References

- [az lock create](https://learn.microsoft.com/en-us/cli/azure/lock?view=azure-cli-latest#az-lock-create)
- [Lock your Azure resources to protect your infrastructure - Azure Resource Manager](https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/lock-resources)

Checked 2026-10-23 with Azure CLI 2.91.0: command syntax, flags and links.

## Testing Compliance
Remove a resource lock from a storage account; it should be detected.

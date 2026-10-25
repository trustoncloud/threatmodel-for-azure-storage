# Remediation

A virtual network rule on the account in the finding admits a subnet that is not authorized. Remove it:

```bash
az storage account network-rule remove --account-name <account-name> --resource-group <resource-group> --subnet <subnet-id>
```

If the subnet is approved, add its resource ID to `authorized_subnet_ids` in the rule's configuration instead. Replace `<account-name>` and `<resource-group>` with the storage account in the finding, and `<subnet-id>` with the subnet's resource ID.

## References

- [az storage account network-rule remove](https://learn.microsoft.com/en-us/cli/azure/storage/account/network-rule?view=azure-cli-latest#az-storage-account-network-rule-remove)
- [Azure Storage firewall rules and network access](https://learn.microsoft.com/en-us/azure/storage/common/storage-network-security)

Checked 2026-10-23 with Azure CLI 2.91.0: command syntax, flags and links.

## Testing Compliance
Configure a storage account with an unauthorized virtual network rule; it should be detected.

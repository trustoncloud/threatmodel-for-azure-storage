# Remediation

The account in the finding admits traffic by IP rule, or its firewall does not deny by default. Remove every IP rule and reach the account through private endpoints or virtual network rules instead:

```bash
az storage account network-rule remove --account-name <account-name> --resource-group <resource-group> --ip-address <ip-range>
az storage account update --name <account-name> --resource-group <resource-group> --default-action Deny
```

Replace `<account-name>` and `<resource-group>` with the storage account in the finding, and `<ip-range>` with each range the account lists.

## References

- [az storage account network-rule remove](https://learn.microsoft.com/en-us/cli/azure/storage/account/network-rule?view=azure-cli-latest#az-storage-account-network-rule-remove)
- [az storage account update](https://learn.microsoft.com/en-us/cli/azure/storage/account?view=azure-cli-latest#az-storage-account-update)
- [Azure Storage firewall rules and network access](https://learn.microsoft.com/en-us/azure/storage/common/storage-network-security)

Checked 2026-10-23 with Azure CLI 2.91.0: command syntax, flags and links.

## Testing Compliance
Configure a storage account firewall to allow an unauthorized IP; it should be detected.

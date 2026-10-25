# Remediation

The account in the finding lets traffic bypass its network rules for a service that is not authorized. Allow only the authorized bypass:

```bash
az storage account update --name <account-name> --resource-group <resource-group> --bypass AzureServices
```

Use `--bypass None` for no bypass. If the bypass is approved, add it to `authorized_network_bypass` in the rule's configuration instead. Replace `<account-name>` and `<resource-group>` with the storage account in the finding.

## References

- [az storage account update](https://learn.microsoft.com/en-us/cli/azure/storage/account?view=azure-cli-latest#az-storage-account-update)
- [Azure Storage firewall rules and network access](https://learn.microsoft.com/en-us/azure/storage/common/storage-network-security)

Checked 2026-10-23 with Azure CLI 2.91.0: command syntax, flags and links. Behaviour verified in a lab on 2026-10-23.

## Testing Compliance
Configure a storage account with an unauthorized network ACL bypass configuration; it should be detected.

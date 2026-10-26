# Remediation

The account in the finding is encrypted with a customer-managed key that is not authorized. Point it at an authorized key; the account's identity needs access to that key first:

```bash
az storage account update --name <account-name> --resource-group <resource-group> --encryption-key-source Microsoft.Keyvault --encryption-key-vault <vault-uri> --encryption-key-name <key-name>
```

If the key is approved, add its versionless URL to `authorized_key_urls` in the rule's configuration instead. Replace `<account-name>` and `<resource-group>` with the storage account in the finding, and `<vault-uri>` and `<key-name>` with the authorized key.

## References

- [az storage account update](https://learn.microsoft.com/en-us/cli/azure/storage/account?view=azure-cli-latest#az-storage-account-update)
- [Configure customer-managed keys in the same tenant for an existing storage account - Azure Storage](https://learn.microsoft.com/en-us/azure/storage/common/customer-managed-keys-configure-existing-account)

Checked 2026-10-23 with Azure CLI 2.91.0: command syntax, flags and links.

## Testing Compliance
Modify a required storage account to use an unauthorized CMK; it should be detected.

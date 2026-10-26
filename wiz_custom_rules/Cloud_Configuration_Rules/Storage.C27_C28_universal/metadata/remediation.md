# Remediation

The account in the finding allows Shared Key, so SAS tokens signed with its keys can be issued, and it has no SAS expiration policy, a policy longer than the approved maximum, or a policy that only logs longer tokens. Set the policy to the approved maximum and block longer tokens:

```bash
az storage account update --name <account-name> --resource-group <resource-group> --sas-expiration-period 1.00:00:00 --sas-expiration-action Block
```

The period uses Azure's `D.HH:MM:SS` form; match it to `max_sas_expiration_period` in the rule's configuration. Where no client needs SAS tokens signed with an account key, turning Shared Key off removes them entirely:

```bash
az storage account update --name <account-name> --resource-group <resource-group> --allow-shared-key-access false
```

The rule checks the account's SAS policy. Tokens already issued are not visible to it; rotate the account keys to revoke them. Replace `<account-name>` and `<resource-group>` with the storage account in the finding.

## References

- [az storage account update](https://learn.microsoft.com/en-us/cli/azure/storage/account?view=azure-cli-latest#az-storage-account-update)
- [Configure an expiration policy for shared access signatures (SAS) - Azure Storage](https://learn.microsoft.com/en-us/azure/storage/common/sas-expiration-policy)

Checked 2026-10-23 with Azure CLI 2.91.0: command syntax, flags and links. Behaviour verified in a lab on 2026-10-23.

## Testing Compliance
Configure or use a SAS token outside authorized storage accounts, services, permissions, expiration, or access methods; it should be detected.

# Remediation

The container in the finding has no immutability policy. Add a time-based retention policy:

```bash
az storage container immutability-policy create --account-name <account-name> --resource-group <resource-group> --container-name <container-name> --period <retention-days>
```

A new policy starts unlocked; lock it once the retention period is final, since a locked policy cannot be shortened or removed. Replace `<account-name>`, `<resource-group>` and `<container-name>` with the container in the finding, and `<retention-days>` with the approved retention.

## References

- [az storage container immutability-policy create](https://learn.microsoft.com/en-us/cli/azure/storage/container/immutability-policy?view=azure-cli-latest#az-storage-container-immutability-policy-create)
- [Immutable Storage for Blob Data Overview - Azure Storage](https://learn.microsoft.com/en-us/azure/storage/blobs/immutable-storage-overview)

Checked 2026-10-23 with Azure CLI 2.91.0: command syntax, flags and links.

## Testing Compliance
Disable or remove the immutability policy from a storage container that is required to have immutability enabled; it should be detected.

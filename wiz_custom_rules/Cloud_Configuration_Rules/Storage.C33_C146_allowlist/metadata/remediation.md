# Remediation

The container in the finding is required to be immutable, and its configuration shows no immutability policy of its own. Either it has no protection, or it relies on a default policy set on the storage account, which the container's configuration does not show. Check the account first:

```bash
az storage account show --name <account-name> --resource-group <resource-group> --query immutableStorageWithVersioning
```

If the account has version-level immutability with a default policy that meets your retention requirement, the container is protected: keep that policy, and accept the finding as a verified exception or add a container policy as below to make the protection visible. If the account has no such policy, add a time-based retention policy to the container:

```bash
az storage container immutability-policy create --account-name <account-name> --resource-group <resource-group> --container-name <container-name> --period <retention-days>
```

A new policy starts unlocked; lock it once the retention period is final, since a locked policy cannot be shortened or removed. Version-level immutability support on its own sets no retention period. The container list is `required_containers` in the rule's configuration. Replace `<account-name>`, `<resource-group>` and `<container-name>` with the container in the finding, and `<retention-days>` with the approved retention.

## References

- [az storage account show](https://learn.microsoft.com/en-us/cli/azure/storage/account?view=azure-cli-latest#az-storage-account-show)
- [az storage container immutability-policy create](https://learn.microsoft.com/en-us/cli/azure/storage/container/immutability-policy?view=azure-cli-latest#az-storage-container-immutability-policy-create)
- [Immutable Storage for Blob Data Overview - Azure Storage](https://learn.microsoft.com/en-us/azure/storage/blobs/immutable-storage-overview)

Checked 2026-10-23 with Azure CLI 2.91.0: command syntax, flags and links.

## Testing Compliance
Disable or remove the immutability policy from a storage container that is required to have immutability enabled; it should be detected.

# Remediation

The account in the finding has a private endpoint connection that is not authorized or not approved. Find the connection, then remove it, or approve it if it is expected:

```bash
az storage account show --name <account-name> --resource-group <resource-group> --query privateEndpointConnections
az storage account private-endpoint-connection delete --account-name <account-name> --resource-group <resource-group> --name <connection-name> --yes
```

If the endpoint is approved, add its resource ID to `authorized_endpoints` in the rule's configuration instead. Replace `<account-name>` and `<resource-group>` with the storage account in the finding, and `<connection-name>` with the connection's name.

## References

- [az storage account show](https://learn.microsoft.com/en-us/cli/azure/storage/account?view=azure-cli-latest#az-storage-account-show)
- [az storage account private-endpoint-connection delete](https://learn.microsoft.com/en-us/cli/azure/storage/account/private-endpoint-connection?view=azure-cli-latest#az-storage-account-private-endpoint-connection-delete)
- [Use private endpoints - Azure Storage](https://learn.microsoft.com/en-us/azure/storage/common/storage-private-endpoints)

Checked 2026-10-23 with Azure CLI 2.91.0: command syntax, flags and links.

## Testing Compliance
Configure an unauthorized private endpoint on a storage account; it should be detected.

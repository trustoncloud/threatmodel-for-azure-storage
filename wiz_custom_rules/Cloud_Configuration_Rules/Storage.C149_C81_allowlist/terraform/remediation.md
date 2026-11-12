Turn Shared Key off and default to Entra ID on every account in `required_secure_accounts`:

```hcl
resource "azurerm_storage_account" "example" {
  shared_access_key_enabled       = false
  default_to_oauth_authentication = true
}
```

`shared_access_key_enabled` defaults to true, so set it explicitly.

Requiring Microsoft Entra ID as the portal default is controlled by `require_oauth_default` in the rule's configuration (default `true`). The portal default only chooses how the portal authorizes data access; it does not turn Shared Key off. Setting `require_oauth_default` to `false` drops only the portal default check: Shared Key must still be disabled.

## References

- [azurerm_storage_account (hashicorp/azurerm 5.10.0)](https://registry.terraform.io/providers/hashicorp/azurerm/5.10.0/docs/resources/storage_account)
- [Default to Microsoft Entra authorization in the Azure portal](https://learn.microsoft.com/en-us/azure/storage/blobs/authorize-data-operations-portal#default-to-microsoft-entra-authorization-in-the-azure-portal)

Checked 2026-10-23 against hashicorp/azurerm 4.81.0 and 5.10.0: resources, arguments and links.

Leave SFTP off and give any local user SSH key sign-in only:

```hcl
resource "azurerm_storage_account" "example" {
  sftp_enabled = false
}

resource "azurerm_storage_account_local_user" "example" {
  ssh_password_enabled = false
}
```

This mode reports SFTP with local users on any account and any local user that may sign in with a password. Which local users exist and the permissions each one holds are reviewed in the allowlist mode only.

## References

- [azurerm_storage_account (hashicorp/azurerm 5.10.0)](https://registry.terraform.io/providers/hashicorp/azurerm/5.10.0/docs/resources/storage_account)
- [azurerm_storage_account_local_user (hashicorp/azurerm 5.10.0)](https://registry.terraform.io/providers/hashicorp/azurerm/5.10.0/docs/resources/storage_account_local_user)

Checked 2026-10-23 against hashicorp/azurerm 4.81.0 and 5.10.0: resources, arguments and links.

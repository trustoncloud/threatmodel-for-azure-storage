Leave SFTP off unless the account is in `authorized_sftp_accounts`. A local user belongs to an authorized account, is listed in `authorized_local_users` as `<account name>/<local user name>`, signs in with SSH keys only, and holds only the permissions in `allowed_local_user_permissions` (delete is left out by default):

```hcl
resource "azurerm_storage_account" "example" {
  sftp_enabled = false
}

resource "azurerm_storage_account_local_user" "example" {
  storage_account_id   = azurerm_storage_account.example.id
  ssh_password_enabled = false

  permission_scope {
    service       = "blob"
    resource_name = "example-container"

    permissions {
      read = true
      list = true
    }
  }
}
```

The local user's account is read from `storage_account_id`: a reference to an account declared in the same configuration, or a literal account ID. A value the source scan cannot resolve, such as a variable passed at apply time, is reported as not resolved by this source scan. A variable that declares a default is checked at that default, because the scan reads the Terraform source; Terraform can deploy a value passed in its place, and a passing scan does not cover that value.

Leaving delete out of `allowed_local_user_permissions` is a conservative default: add `"delete"` to the list to authorize deletion explicitly. Write permission still allows changes that overwrite data, so grant it only where a user needs it.

## References

- [azurerm_storage_account (hashicorp/azurerm 5.10.0)](https://registry.terraform.io/providers/hashicorp/azurerm/5.10.0/docs/resources/storage_account)
- [azurerm_storage_account_local_user (hashicorp/azurerm 5.10.0)](https://registry.terraform.io/providers/hashicorp/azurerm/5.10.0/docs/resources/storage_account_local_user)

Checked 2026-10-23 against hashicorp/azurerm 4.81.0 and 5.10.0: resources, arguments and links.

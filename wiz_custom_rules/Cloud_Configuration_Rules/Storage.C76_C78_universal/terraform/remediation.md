Declare the account in `required_region`:

```hcl
resource "azurerm_storage_account" "example" {
  location = "eastus"
}
```

Changing `location` makes Terraform replace the account, so move its data first.

A location set from another resource is read when it copies the location of an `azurerm_resource_group` declared in the same file. Any other value the source scan cannot resolve is reported. A variable that declares a default is checked at that default, because the scan reads the Terraform source. Terraform can deploy a value passed in its place, and a passing scan does not cover that value.

## References

- [azurerm_storage_account (hashicorp/azurerm 5.10.0)](https://registry.terraform.io/providers/hashicorp/azurerm/5.10.0/docs/resources/storage_account)

Checked 2026-10-23 against hashicorp/azurerm 4.81.0 and 5.10.0: resources, arguments and links.

Declare the account in a region not listed in `forbidden_regions`:

```hcl
resource "azurerm_storage_account" "example" {
  location = "eastus"
}
```

Changing `location` makes Terraform replace the account, so move its data first.

A location set from another resource is read when it copies the location of an `azurerm_resource_group` declared in the same file. Any other value the source scan cannot resolve is reported as not resolved by this source scan, since it could name a forbidden region; the finding does not claim the region is forbidden. A variable that declares a default is checked at that default, because the scan reads the Terraform source. Terraform can deploy a value passed in its place, and a passing scan does not cover that value.

A geo-redundant replication type (GRS, RAGRS, GZRS, RAGZRS) also stores data in the paired region Azure picks, which the Terraform source does not name. The deployed account's secondary region is checked by the cloud rule.

## References

- [azurerm_storage_account (hashicorp/azurerm 5.10.0)](https://registry.terraform.io/providers/hashicorp/azurerm/5.10.0/docs/resources/storage_account)

Checked 2026-10-23 against hashicorp/azurerm 4.81.0 and 5.10.0: resources, arguments and links.

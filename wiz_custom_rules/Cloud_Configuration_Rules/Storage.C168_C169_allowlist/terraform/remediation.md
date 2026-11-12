List only authorized subnets in `virtual_network_subnet_ids`, inline in `network_rules` or on `azurerm_storage_account_network_rules`, or add a subnet to `authorized_subnet_ids` once approved. Write each subnet as its full resource ID:

```hcl
resource "azurerm_storage_account" "example" {
  network_rules {
    default_action             = "Deny"
    virtual_network_subnet_ids = ["/subscriptions/<subscription-id>/resourceGroups/<resource-group>/providers/Microsoft.Network/virtualNetworks/<vnet>/subnets/<subnet>"]
  }
}
```

Subnet IDs are compared in full, without regard to case. A subnet written as a reference to another resource (such as `azurerm_subnet.app.id`) or taken from a variable with no default is reported for review: its authorization cannot be verified from the Terraform source, because the subscription and resource group it resolves to are known only at apply time. A variable that declares a default is checked at that default, because the scan reads the Terraform source. Terraform can deploy a value passed in its place, and a passing scan does not cover that value.

## References

- [azurerm_storage_account (hashicorp/azurerm 5.10.0)](https://registry.terraform.io/providers/hashicorp/azurerm/5.10.0/docs/resources/storage_account)

Checked 2026-10-23 against hashicorp/azurerm 4.81.0 and 5.10.0: resources, arguments and links.

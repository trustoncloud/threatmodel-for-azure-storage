Declare an immutability policy for every container in `required_containers`:

```hcl
resource "azurerm_storage_container_immutability_policy" "example" {
  storage_container_resource_manager_id = azurerm_storage_container.example.id
  immutability_period_in_days           = 30
}
```

## References

- [azurerm_storage_container_immutability_policy (hashicorp/azurerm 5.10.0)](https://registry.terraform.io/providers/hashicorp/azurerm/5.10.0/docs/resources/storage_container_immutability_policy)

Checked 2026-10-23 against hashicorp/azurerm 4.81.0 and 5.10.0: resources, arguments and links.

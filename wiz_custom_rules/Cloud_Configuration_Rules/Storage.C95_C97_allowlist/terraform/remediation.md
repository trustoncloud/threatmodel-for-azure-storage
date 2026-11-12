Declare CORS rules that use only authorized origins, methods and headers, or add the values to the rule's configuration once approved. Blob and file CORS rules sit on the account; queue and table CORS rules sit on their own resources (azurerm 4.x also accepts an inline `queue_properties` block):

```hcl
resource "azurerm_storage_account" "example" {
  blob_properties {
    cors_rule {
      allowed_origins    = ["https://myapp.contoso.com"]
      allowed_methods    = ["GET"]
      allowed_headers    = ["Content-Type"]
      exposed_headers    = ["x-ms-request-id"]
      max_age_in_seconds = 200
    }
  }
}

resource "azurerm_storage_account_queue_properties" "example" {
  storage_account_id = azurerm_storage_account.example.id

  cors_rule {
    allowed_origins    = ["https://myapp.contoso.com"]
    allowed_methods    = ["GET"]
    allowed_headers    = ["Content-Type"]
    exposed_headers    = ["x-ms-request-id"]
    max_age_in_seconds = 200
  }
}
```

The same `cors_rule` block applies to `azurerm_storage_account_table_properties`.

## References

- [azurerm_storage_account (hashicorp/azurerm 5.10.0)](https://registry.terraform.io/providers/hashicorp/azurerm/5.10.0/docs/resources/storage_account)
- [azurerm_storage_account_queue_properties (hashicorp/azurerm 5.10.0)](https://registry.terraform.io/providers/hashicorp/azurerm/5.10.0/docs/resources/storage_account_queue_properties)
- [azurerm_storage_account_table_properties (hashicorp/azurerm 5.10.0)](https://registry.terraform.io/providers/hashicorp/azurerm/5.10.0/docs/resources/storage_account_table_properties)

Checked 2026-10-23 against hashicorp/azurerm 4.81.0 and 5.10.0: resources, arguments and links.

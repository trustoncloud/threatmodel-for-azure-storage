Declare CORS rules that use only authorized origins and methods, or add the values to the rule's configuration once approved:

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
```

## References

- [azurerm_storage_account (hashicorp/azurerm 5.10.0)](https://registry.terraform.io/providers/hashicorp/azurerm/5.10.0/docs/resources/storage_account)

Checked 2026-10-23 against hashicorp/azurerm 4.81.0 and 5.10.0: resources, arguments and links.

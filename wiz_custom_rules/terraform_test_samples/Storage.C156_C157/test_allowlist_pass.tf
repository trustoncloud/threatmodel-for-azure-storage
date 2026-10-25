# Storage.C157 (authorized_stored_access_policy) - allowlist - COMPLIANT

resource "azurerm_storage_share" "read_only_policy" {
  name               = "example-share"
  storage_account_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/example-rg/providers/Microsoft.Storage/storageAccounts/examplesapok"
  quota              = 50

  acl {
    id = "examplereadonly"

    access_policy {
      permissions = "rl"
      start       = "2026-01-01T00:00:00Z"
      expiry      = "2026-01-02T00:00:00Z"
    }
  }
}

resource "azurerm_storage_table" "read_only_policy" {
  name                 = "exampletable"
  storage_account_name = "examplesapok"

  acl {
    id = "examplereadonly"

    access_policy {
      permissions = "r"
      start       = "2026-01-01T00:00:00Z"
      expiry      = "2026-01-02T00:00:00Z"
    }
  }
}

# A share without stored access policies
resource "azurerm_storage_share" "no_policy" {
  name               = "example-share-plain"
  storage_account_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/example-rg/providers/Microsoft.Storage/storageAccounts/examplesapok"
  quota              = 50
}

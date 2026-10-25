# Storage.C157 (authorized_stored_access_policy) - allowlist - VIOLATING

# Unauthorized policy id that also grants write and delete: 2 findings
resource "azurerm_storage_share" "unauthorized_policy" {
  name               = "example-share"
  storage_account_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/example-rg/providers/Microsoft.Storage/storageAccounts/examplesapbad"
  quota              = 50

  acl {
    id = "examplefullaccess"

    access_policy {
      permissions = "rwdl"
    }
  }
}

# Two acl blocks: one authorized, one granting delete under the approved id: 1 finding
resource "azurerm_storage_table" "delete_permission" {
  name                 = "exampletable"
  storage_account_name = "examplesapbad"

  acl {
    id = "examplereadonly"

    access_policy {
      permissions = "r"
      start       = "2026-01-01T00:00:00Z"
      expiry      = "2026-01-02T00:00:00Z"
    }
  }

  acl {
    id = "examplereadonly"

    access_policy {
      permissions = "rd"
      start       = "2026-01-01T00:00:00Z"
      expiry      = "2026-01-02T00:00:00Z"
    }
  }
}

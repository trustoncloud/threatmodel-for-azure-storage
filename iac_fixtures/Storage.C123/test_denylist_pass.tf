# Storage.C123 (file_share_security_protocol_required) - denylist - COMPLIANT (0 findings)

# Only strong (non-forbidden) encryption methods
resource "azurerm_storage_account" "strong_only" {
  name                     = "any-share"
  resource_group_name      = "rg-test"
  location                 = "eastus"
  account_tier             = "Standard"
  account_replication_type = "LRS"

  share_properties {
    smb {
      kerberos_ticket_encryption_type = ["AES-256"]
      channel_encryption_type         = ["AES-256-GCM"]
    }
  }
}

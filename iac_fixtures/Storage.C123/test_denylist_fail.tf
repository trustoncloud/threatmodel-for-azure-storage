# Storage.C123 (file_share_security_protocol_required) - denylist - VIOLATING

# Forbidden Kerberos (RC4-HMAC) and forbidden Channel (AES-128-GCM): 2 findings
resource "azurerm_storage_account" "forbidden_methods" {
  name                     = "any-share"
  resource_group_name      = "rg-test"
  location                 = "eastus"
  account_tier             = "Standard"
  account_replication_type = "LRS"

  share_properties {
    smb {
      kerberos_ticket_encryption_type = ["RC4-HMAC", "AES-256"]
      channel_encryption_type         = ["AES-128-GCM"]
    }
  }
}

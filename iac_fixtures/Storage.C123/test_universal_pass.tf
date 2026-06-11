# Storage.C123 (file_share_security_protocol_required) - universal - COMPLIANT (0 findings)

# SMB block includes both strong values
resource "azurerm_storage_account" "compliant_smb" {
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

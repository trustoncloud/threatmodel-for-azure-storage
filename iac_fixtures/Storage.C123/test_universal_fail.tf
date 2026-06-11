# Storage.C123 (file_share_security_protocol_required) - universal - VIOLATING

# SMB block present but missing both strong values: 2 findings
resource "azurerm_storage_account" "weak_smb" {
  name                     = "any-share"
  resource_group_name      = "rg-test"
  location                 = "eastus"
  account_tier             = "Standard"
  account_replication_type = "LRS"

  share_properties {
    smb {
      kerberos_ticket_encryption_type = ["RC4-HMAC"]
      channel_encryption_type         = ["AES-128-CCM"]
    }
  }
}

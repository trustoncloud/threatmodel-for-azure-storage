# Storage.C123 (file_share_security_protocol_required) - allowlist - COMPLIANT (0 findings)

# Required share with strong Kerberos + Channel encryption
resource "azurerm_storage_account" "required_compliant" {
  name                     = "finance-share"
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

# Non-required share is not enforced even with weak settings
resource "azurerm_storage_account" "non_required" {
  name                     = "public-share"
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

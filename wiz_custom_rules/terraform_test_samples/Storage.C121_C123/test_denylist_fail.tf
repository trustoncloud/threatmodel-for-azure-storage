# Storage.C123 (file_share_security_protocol_required) - denylist - VIOLATING

# Forbidden Kerberos (RC4-HMAC) and forbidden Channel (AES-128-GCM): 2 findings
resource "azurerm_storage_account" "forbidden_methods" {
  name                     = "exampleanyshare"
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

# share_properties omitted: Azure default allows RC4-HMAC, AES-128-CCM and AES-128-GCM: 3 findings
resource "azurerm_storage_account" "default_smb" {
  name                     = "exampledefaultshare"
  resource_group_name      = "rg-test"
  location                 = "eastus"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# channel_encryption_type not resolved by the source scan: 1 finding
resource "azurerm_storage_account" "unknown_channel" {
  name                     = "exampleunknownchan"
  resource_group_name      = "rg-test"
  location                 = "eastus"
  account_tier             = "Standard"
  account_replication_type = "LRS"

  share_properties {
    smb {
      kerberos_ticket_encryption_type = ["AES-256"]
      channel_encryption_type         = var.unknown_channel
    }
  }
}

variable "unknown_channel" {
  type = list(string)
}

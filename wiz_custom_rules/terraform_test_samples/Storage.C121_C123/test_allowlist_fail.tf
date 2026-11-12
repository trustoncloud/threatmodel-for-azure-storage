# Storage.C123 (file_share_security_protocol_required) - allowlist - VIOLATING

# Required share missing strong Kerberos (RC4-HMAC instead of AES-256): 1 finding
resource "azurerm_storage_account" "required_weak_kerberos" {
  name                     = "examplefinanceshare"
  resource_group_name      = "rg-test"
  location                 = "eastus"
  account_tier             = "Standard"
  account_replication_type = "LRS"

  share_properties {
    smb {
      kerberos_ticket_encryption_type = ["RC4-HMAC"]
      channel_encryption_type         = ["AES-256-GCM"]
    }
  }
}

# Required share missing strong Channel (AES-128-GCM instead of AES-256-GCM): 1 finding
resource "azurerm_storage_account" "required_weak_channel" {
  name                     = "examplehrshare"
  resource_group_name      = "rg-test"
  location                 = "eastus"
  account_tier             = "Standard"
  account_replication_type = "LRS"

  share_properties {
    smb {
      kerberos_ticket_encryption_type = ["AES-256"]
      channel_encryption_type         = ["AES-128-GCM"]
    }
  }
}

# Required account, share_properties omitted: Azure default allows weak Kerberos and channel values: 2 findings
resource "azurerm_storage_account" "required_default" {
  name                     = "examplefinanceshare"
  resource_group_name      = "rg-test"
  location                 = "eastus"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# Required account allows RC4-HMAC next to AES-256: 1 finding
resource "azurerm_storage_account" "required_mixed" {
  name                     = "examplehrshare"
  resource_group_name      = "rg-test"
  location                 = "eastus"
  account_tier             = "Standard"
  account_replication_type = "LRS"

  share_properties {
    smb {
      kerberos_ticket_encryption_type = ["AES-256", "RC4-HMAC"]
      channel_encryption_type         = ["AES-256-GCM"]
    }
  }
}

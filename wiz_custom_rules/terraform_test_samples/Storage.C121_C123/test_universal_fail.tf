# Storage.C123 (file_share_security_protocol_required) - universal - VIOLATING

# Weak values only: 2 findings
resource "azurerm_storage_account" "weak_smb" {
  name                     = "exampleweakshare"
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

# Strong values alongside weak ones, channel left at its default: 2 findings
resource "azurerm_storage_account" "mixed_smb" {
  name                     = "examplemixedshare"
  resource_group_name      = "rg-test"
  location                 = "eastus"
  account_tier             = "Standard"
  account_replication_type = "LRS"

  share_properties {
    smb {
      kerberos_ticket_encryption_type = ["AES-256", "RC4-HMAC"]
    }
  }
}

# share_properties omitted, account_kind omitted (StorageV2): both lists at the Azure default: 2 findings
resource "azurerm_storage_account" "default_smb" {
  name                     = "exampledefaultshare"
  resource_group_name      = "rg-test"
  location                 = "eastus"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# FileStorage account, smb block declared empty of encryption lists: 2 findings
resource "azurerm_storage_account" "file_storage_default" {
  name                     = "examplefilestorage"
  resource_group_name      = "rg-test"
  location                 = "eastus"
  account_kind             = "FileStorage"
  account_tier             = "Premium"
  account_replication_type = "LRS"

  share_properties {
    smb {
      versions = ["SMB3.1.1"]
    }
  }
}

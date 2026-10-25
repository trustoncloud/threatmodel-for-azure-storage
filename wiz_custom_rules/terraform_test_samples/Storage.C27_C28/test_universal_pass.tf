# Storage.C28 (sas_expiration_policy) - universal - COMPLIANT

# SAS expiration policy within the 1-day maximum, action Block
resource "azurerm_storage_account" "sas_policy_block" {
  name                     = "examplesasblock"
  resource_group_name      = "example-rg"
  location                 = "eastus"
  account_tier             = "Standard"
  account_replication_type = "LRS"

  sas_policy {
    expiration_period = "0.04:00:00"
    expiration_action = "Block"
  }
}

# Shared Key disabled: no SAS can be signed with an account key
resource "azurerm_storage_account" "shared_key_off" {
  name                      = "examplenosharedkey"
  resource_group_name       = "example-rg"
  location                  = "eastus"
  account_tier              = "Standard"
  account_replication_type  = "LRS"
  shared_access_key_enabled = false
}

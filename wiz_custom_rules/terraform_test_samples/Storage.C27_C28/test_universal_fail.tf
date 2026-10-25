# Storage.C28 (sas_expiration_policy) - universal - VIOLATING

# Shared Key on by default and no SAS expiration policy: 1 finding
resource "azurerm_storage_account" "no_sas_policy" {
  name                     = "examplenosaspolicy"
  resource_group_name      = "example-rg"
  location                 = "eastus"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# Period longer than 1 day: 1 finding
resource "azurerm_storage_account" "sas_period_too_long" {
  name                     = "examplesaslong"
  resource_group_name      = "example-rg"
  location                 = "eastus"
  account_tier             = "Standard"
  account_replication_type = "LRS"

  sas_policy {
    expiration_period = "7.00:00:00"
    expiration_action = "Block"
  }
}

# Action left at its Log default: 1 finding
resource "azurerm_storage_account" "sas_action_log" {
  name                     = "examplesaslog"
  resource_group_name      = "example-rg"
  location                 = "eastus"
  account_tier             = "Standard"
  account_replication_type = "LRS"

  sas_policy {
    expiration_period = "1.00:00:00"
  }
}

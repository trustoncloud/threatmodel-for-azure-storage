# Storage.C105 (malware_scanning_enabled) - universal - VIOLATING

# No Defender for Storage resource and no subscription plan: 1 finding
resource "azurerm_storage_account" "not_scanned" {
  name                     = "examplenotscanned"
  resource_group_name      = "example-rg"
  location                 = "eastus"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# Account-level override that leaves scanning off: 2 findings (account and override)
resource "azurerm_storage_account" "override_off" {
  name                     = "exampleoverrideoff"
  resource_group_name      = "example-rg"
  location                 = "eastus"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_security_center_storage_defender" "override_off" {
  storage_account_id                     = azurerm_storage_account.override_off.id
  override_subscription_settings_enabled = true
  malware_scanning_on_upload_enabled     = false
}

# Storage.C105 (malware_scanning_enabled) - universal - COMPLIANT

resource "azurerm_storage_account" "scanned" {
  name                     = "examplescanned"
  resource_group_name      = "example-rg"
  location                 = "eastus"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# Account-level malware scanning on upload
resource "azurerm_security_center_storage_defender" "scanned" {
  storage_account_id                 = azurerm_storage_account.scanned.id
  malware_scanning_on_upload_enabled = true
}

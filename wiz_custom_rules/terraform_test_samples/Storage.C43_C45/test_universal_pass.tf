# This is testing Storage.C45 (storage_firewall_restricted) - universal variant
# Expected outcome: COMPLIANT (0 findings)

# Test case 1: Inline firewall Deny with NO ip_rules (private endpoint access only)
resource "azurerm_storage_account" "compliant_c45_universal_inline" {
  name                     = "compliantunivinline"
  resource_group_name      = "rg-test"
  location                 = "eastus"
  account_tier             = "Standard"
  account_replication_type = "LRS"
  network_rules {
    default_action = "Deny"
    ip_rules       = []
  }
}

# Test case 2: Standalone rules resource linked to account, Deny, NO ip_rules
resource "azurerm_storage_account" "compliant_c45_universal_standalone" {
  name                     = "compliantunivstandalone"
  resource_group_name      = "rg-test"
  location                 = "eastus"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_account_network_rules" "standalone_compliant" {
  storage_account_id = azurerm_storage_account.compliant_c45_universal_standalone.id
  default_action     = "Deny"
  ip_rules           = []
}

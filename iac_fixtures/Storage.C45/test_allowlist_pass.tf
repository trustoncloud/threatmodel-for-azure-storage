# This is testing Storage.C45 (storage_firewall_restricted) - allowlist variant
# Expected outcome: COMPLIANT (0 findings)

# Test case 1: Inline firewall restricted to authorized IP ("20.50.100.10")
resource "azurerm_storage_account" "compliant_c45_inline" {
  name                     = "compliantfirewallinline"
  resource_group_name      = "rg-test"
  location                 = "eastus"
  account_tier             = "Standard"
  account_replication_type = "LRS"
  network_rules {
    default_action = "Deny"
    ip_rules       = ["20.50.100.10"]
  }
}

# Test case 2: Standalone rules resource linked to account, Deny, authorized IP ("40.70.150.50" in "40.70.150.0/24")
resource "azurerm_storage_account" "compliant_c45_standalone" {
  name                     = "compliantfirewallstandalone"
  resource_group_name      = "rg-test"
  location                 = "eastus"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_account_network_rules" "standalone_compliant" {
  storage_account_id = azurerm_storage_account.compliant_c45_standalone.id
  default_action     = "Deny"
  ip_rules           = ["40.70.150.50"]
}

# This is testing Storage.C45 (storage_firewall_restricted) - universal variant
# Expected outcome: VIOLATING (2 findings: universal permits no IP rules)

# Test case 1: Inline firewall restricted to an IP rule (even the allowlist IP fails universal)
resource "azurerm_storage_account" "violating_c45_universal_inline" {
  name                     = "violatingunivinline"
  resource_group_name      = "rg-test"
  location                 = "eastus"
  account_tier             = "Standard"
  account_replication_type = "LRS"
  network_rules {
    default_action = "Deny"
    ip_rules       = ["20.50.100.10"] # Violating (universal allows no IP rules)
  }
}

# Test case 2: Standalone rules resource with IP rule
resource "azurerm_storage_account" "violating_c45_universal_standalone" {
  name                     = "violatingunivstandalone"
  resource_group_name      = "rg-test"
  location                 = "eastus"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_account_network_rules" "standalone_violating" {
  storage_account_id = azurerm_storage_account.violating_c45_universal_standalone.id
  default_action     = "Deny"
  ip_rules           = ["40.70.150.50"] # Violating (universal allows no IP rules)
}

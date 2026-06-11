# This is testing Storage.C45 (storage_firewall_restricted) - allowlist variant
# Expected outcome: VIOLATING (5 findings)

# Test case 1: Inline firewall open (default_action = Allow) [Finding 1]
resource "azurerm_storage_account" "violating_firewall_inline_open" {
  name                     = "violatinginlineopen"
  resource_group_name      = "rg-test"
  location                 = "eastus"
  account_tier             = "Standard"
  account_replication_type = "LRS"
  network_rules {
    default_action = "Allow"
  }
}

# Test case 2: Inline firewall with unauthorized IP rule [Finding 2]
resource "azurerm_storage_account" "violating_firewall_inline_unauth" {
  name                     = "violatinginlineunauth"
  resource_group_name      = "rg-test"
  location                 = "eastus"
  account_tier             = "Standard"
  account_replication_type = "LRS"
  network_rules {
    default_action = "Deny"
    ip_rules       = ["192.168.1.5"]
  }
}

# Test case 3: Standalone firewall open (default_action = Allow) [Finding 3]
resource "azurerm_storage_account" "violating_firewall_standalone_open" {
  name                     = "violatingstandaloneopen"
  resource_group_name      = "rg-test"
  location                 = "eastus"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_account_network_rules" "standalone_open" {
  storage_account_id = azurerm_storage_account.violating_firewall_standalone_open.id
  default_action     = "Allow"
}

# Test case 4: Standalone firewall with unauthorized IP rule [Finding 4]
resource "azurerm_storage_account" "violating_firewall_standalone_unauth" {
  name                     = "violatingstandaloneunauth"
  resource_group_name      = "rg-test"
  location                 = "eastus"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_account_network_rules" "standalone_unauth" {
  storage_account_id = azurerm_storage_account.violating_firewall_standalone_unauth.id
  default_action     = "Deny"
  ip_rules           = ["192.168.1.10"]
}

# Test case 5: Firewall unconfigured / absent [Finding 5]
resource "azurerm_storage_account" "violating_firewall_absence" {
  name                     = "violatingfirewallabsence"
  resource_group_name      = "rg-test"
  location                 = "eastus"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

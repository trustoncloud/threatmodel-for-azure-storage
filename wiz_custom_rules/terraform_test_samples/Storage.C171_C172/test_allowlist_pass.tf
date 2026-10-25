# Storage.C172 (authorized_network_bypass) - allowlist - COMPLIANT

resource "azurerm_storage_account" "azure_services_bypass" {
  name                     = "examplebypassok"
  resource_group_name      = "example-rg"
  location                 = "eastus"
  account_tier             = "Standard"
  account_replication_type = "LRS"

  network_rules {
    default_action = "Deny"
    bypass         = ["AzureServices"]
  }
}

resource "azurerm_storage_account_network_rules" "no_bypass" {
  storage_account_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/example-rg/providers/Microsoft.Storage/storageAccounts/examplenobypass"
  default_action     = "Deny"
  bypass             = ["None"]
}

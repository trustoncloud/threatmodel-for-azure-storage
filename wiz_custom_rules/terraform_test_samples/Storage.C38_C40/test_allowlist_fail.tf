# Storage.C40 (private_endpoint_authorized) - allowlist - VIOLATING

variable "target_id" {
  type = string
}

resource "azurerm_storage_account" "sa" {
  name                     = "examplestorageacct"
  resource_group_name      = "rg-test"
  location                 = "eastus"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_private_dns_zone" "blob" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = "net-rg"
}

resource "azurerm_private_dns_zone" "custom" {
  name                = "privatelink.custom.example.net"
  resource_group_name = "net-rg"
}

resource "azurerm_private_dns_zone" "blob_rogue" {
  name                = "privatelink.blob.example.net"
  resource_group_name = "net-rg"
}

# Storage endpoint linked to a zone that is not authorized: 1 finding
resource "azurerm_private_endpoint" "pe_unauth_zone" {
  name                = "pe-prod-01"
  location            = "eastus"
  resource_group_name = "net-rg"
  subnet_id           = "/subscriptions/123/resourceGroups/net-rg/providers/Microsoft.Network/virtualNetworks/vnet/subnets/pe-subnet"

  private_service_connection {
    name                           = "psc"
    private_connection_resource_id = azurerm_storage_account.sa.id
    is_manual_connection           = false
    subresource_names              = ["blob"]
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [azurerm_private_dns_zone.custom.id]
  }
}

# Storage endpoint with no private_dns_zone_group at all: 1 finding
resource "azurerm_private_endpoint" "pe_no_zone" {
  name                = "pe-prod-01"
  location            = "eastus"
  resource_group_name = "net-rg"
  subnet_id           = "/subscriptions/123/resourceGroups/net-rg/providers/Microsoft.Network/virtualNetworks/vnet/subnets/pe-subnet"

  private_service_connection {
    name                           = "psc"
    private_connection_resource_id = azurerm_storage_account.sa.id
    is_manual_connection           = false
    subresource_names              = ["file"]
  }
}

# Zone whose label starts with an authorized zone's label: 1 finding
resource "azurerm_private_endpoint" "pe_zone_lookalike" {
  name                = "pe-prod-01"
  location            = "eastus"
  resource_group_name = "net-rg"
  subnet_id           = "/subscriptions/123/resourceGroups/net-rg/providers/Microsoft.Network/virtualNetworks/vnet/subnets/pe-subnet"

  private_service_connection {
    name                           = "psc"
    private_connection_resource_id = azurerm_storage_account.sa.id
    is_manual_connection           = false
    subresource_names              = ["blob"]
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [azurerm_private_dns_zone.blob_rogue.id]
  }
}

# Literal zone ID of a zone that is not authorized: 1 finding
resource "azurerm_private_endpoint" "pe_literal_zone_unauth" {
  name                = "pe-prod-02"
  location            = "eastus"
  resource_group_name = "net-rg"
  subnet_id           = "/subscriptions/123/resourceGroups/net-rg/providers/Microsoft.Network/virtualNetworks/vnet/subnets/pe-subnet"

  private_service_connection {
    name                           = "psc"
    private_connection_resource_id = azurerm_storage_account.sa.id
    is_manual_connection           = false
    subresource_names              = ["blob"]
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = ["/subscriptions/123/resourceGroups/net-rg/providers/Microsoft.Network/privateDnsZones/privatelink.blob.core.windows.net.example.com"]
  }
}

# Endpoint next door to an authorized one: 1 finding
# Authorized endpoint name in another resource group (by reference): 1 finding
# Endpoint name not resolved by this source scan: 1 finding
# Resource group read from a data source: not resolved by the source scan, 1 finding
# Storage endpoint with a manual connection (boolean): 1 finding
resource "azurerm_private_endpoint" "pe_manual" {
  name                = "pe-prod-01"
  location            = "eastus"
  resource_group_name = "net-rg"
  subnet_id           = "/subscriptions/123/resourceGroups/net-rg/providers/Microsoft.Network/virtualNetworks/vnet/subnets/pe-subnet"

  private_service_connection {
    name                           = "psc"
    private_connection_resource_id = azurerm_storage_account.sa.id
    is_manual_connection           = true
    request_message                = "please approve"
    subresource_names              = ["blob"]
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [azurerm_private_dns_zone.blob.id]
  }
}

# Storage endpoint with a manual connection (string): 1 finding
resource "azurerm_private_endpoint" "pe_manual_string" {
  name                = "pe-prod-02"
  location            = "eastus"
  resource_group_name = "net-rg"
  subnet_id           = "/subscriptions/123/resourceGroups/net-rg/providers/Microsoft.Network/virtualNetworks/vnet/subnets/pe-subnet"

  private_service_connection {
    name                           = "psc"
    private_connection_resource_id = azurerm_storage_account.sa.id
    is_manual_connection           = "true"
    request_message                = "please approve"
    subresource_names              = ["blob"]
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [azurerm_private_dns_zone.blob.id]
  }
}

# Literal storage account target, zone not authorized: 1 finding
resource "azurerm_private_endpoint" "pe_literal_target" {
  name                = "pe-other"
  location            = "eastus"
  resource_group_name = "net-rg"
  subnet_id           = "/subscriptions/123/resourceGroups/net-rg/providers/Microsoft.Network/virtualNetworks/vnet/subnets/pe-subnet"

  private_service_connection {
    name                           = "psc"
    private_connection_resource_id = "/subscriptions/456/resourceGroups/other-rg/providers/Microsoft.Storage/storageAccounts/otheraccount"
    is_manual_connection           = false
    subresource_names              = ["blob"]
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [azurerm_private_dns_zone.custom.id]
  }
}

# Target not resolved, storage sub-resource, zone not authorized: 1 finding
resource "azurerm_private_endpoint" "pe_unresolved_target" {
  name                = "pe-other"
  location            = "eastus"
  resource_group_name = "net-rg"
  subnet_id           = "/subscriptions/123/resourceGroups/net-rg/providers/Microsoft.Network/virtualNetworks/vnet/subnets/pe-subnet"

  private_service_connection {
    name                           = "psc"
    private_connection_resource_id = var.target_id
    is_manual_connection           = false
    subresource_names              = ["blob"]
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [azurerm_private_dns_zone.custom.id]
  }
}

# Authorized name in another resource group (literal): 1 finding

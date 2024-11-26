
resource "azurerm_virtual_network" "this" {
  name                = "${local.project}-vnet"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  address_space       = ["10.2.0.0/18"]
}

resource "azurerm_subnet" "app" {
  name                                          = "main"
  resource_group_name                           = azurerm_virtual_network.this.resource_group_name
  virtual_network_name                          = azurerm_virtual_network.this.name
  address_prefixes                              = ["10.2.0.0/24"]
  private_link_service_network_policies_enabled = true

  delegation {
    name = "default"
    service_delegation {
      name    = "Microsoft.Web/serverFarms"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}

resource "azurerm_subnet" "private_endpoints" {
  name                 = "private-endpoints"
  resource_group_name  = data.azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = ["10.2.1.0/24"]
}

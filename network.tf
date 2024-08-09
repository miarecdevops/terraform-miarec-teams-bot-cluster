resource "azurerm_virtual_network" "network" {
  name                = "${var.environment}-virtual-network"
  address_space       = [var.virtual_network_cidr]
  resource_group_name = var.azure_resource_group
  location            = var.azure_region

  tags = {
    Environment = var.environment
  }
}

resource "azurerm_subnet" "subnet" {
  name                 = "${var.environment}-subnet"
  resource_group_name  = var.azure_resource_group
  virtual_network_name = azurerm_virtual_network.network.name
  address_prefixes     = [var.virtual_vm_subnet_cidr]
}
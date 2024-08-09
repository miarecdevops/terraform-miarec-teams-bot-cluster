# Create Public IP for Load Balancer
resource "azurerm_public_ip" "lb_public_ip" {
  name                = "${var.environment}-lb-ip"
  location            = var.azure_region
  resource_group_name = var.azure_resource_group
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Create Public Load Balancer
resource "azurerm_lb" "lb" {
  name                = "${var.environment}-lb"
  location            = var.azure_region
  resource_group_name = var.azure_resource_group
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "frontend-ipconfig"
    public_ip_address_id = azurerm_public_ip.lb_public_ip.id
  }
}

resource "azurerm_lb_backend_address_pool" "lb_pool" {
  loadbalancer_id      = azurerm_lb.lb.id
  name                 = "${var.environment}-lb-pool"
}


resource "azurerm_lb_probe" "lb_probe" {
  loadbalancer_id     = azurerm_lb.lb.id
  name                = "https-probe"
  port                = 443
  protocol            = "Https"
  probe_threshold     = 3
  number_of_probes    = 2
  request_path        = "/ping"
}

resource "azurerm_lb_rule" "lb_rule_http" {
  loadbalancer_id                = azurerm_lb.lb.id
  name                           = "http-rule"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  disable_outbound_snat          = true
  frontend_ip_configuration_name = "frontend-ipconfig"
  probe_id                       = azurerm_lb_probe.lb_probe.id
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.lb_pool.id]
}


resource "azurerm_lb_rule" "lb_rule_https" {
  loadbalancer_id                = azurerm_lb.lb.id
  name                           = "https-rule"
  protocol                       = "Tcp"
  frontend_port                  = 443
  backend_port                   = 443
  disable_outbound_snat          = true
  frontend_ip_configuration_name = "frontend-ipconfig"
  probe_id                       = azurerm_lb_probe.lb_probe.id
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.lb_pool.id]
}


# ------------------------------------------------------------------
# Associate VM NICs to the Backend Pool of the Load Balancer
# ------------------------------------------------------------------
resource "azurerm_network_interface_backend_address_pool_association" "nic_lb_pool" {
  for_each            = toset(var.vm_computer_names)
  network_interface_id    = azurerm_network_interface.nic[each.key].id
  ip_configuration_name   = "${var.environment}-${each.key}-ip-config"
  backend_address_pool_id = azurerm_lb_backend_address_pool.lb_pool.id
}
resource "random_password" "vm_admin_password" {
  length      = 20
  min_lower   = 1
  min_upper   = 1
  min_numeric = 1
  min_special = 1
  special     = true
}

# Create public IPs
resource "azurerm_public_ip" "ip" {
  for_each            = toset(var.vm_computer_names)
  name                = "${var.environment}-${each.key}-public-ip"
  resource_group_name = var.azure_resource_group
  location            = var.azure_region
  allocation_method   = var.public_ip_allocation_strategy

  tags = {
    Environment = var.environment
  }
}


// ----------------------------------------------------------------------------
// Security group is shared between all virtual machines
// ----------------------------------------------------------------------------
resource "azurerm_network_security_group" "sg" {
  name                = "${var.environment}-sg"
  resource_group_name = var.azure_resource_group
  location            = var.azure_region

  dynamic "security_rule" {
    for_each = var.vm_security_rules
    content {
      name                       = security_rule.value["name"]
      priority                   = security_rule.value["priority"]
      direction                  = security_rule.value["direction"]
      access                     = security_rule.value["access"]
      protocol                   = security_rule.value["protocol"]
      source_port_range          = security_rule.value["source_port_range"]
      destination_port_range     = security_rule.value["destination_port_range"]
      source_address_prefix      = security_rule.value["source_address_prefix"]
      destination_address_prefix = security_rule.value["destination_address_prefix"]
    }
  }

  tags = {
    Environment = var.environment
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Create network interface
resource "azurerm_network_interface" "nic" {
  for_each            = toset(var.vm_computer_names)
  name                = "${var.environment}-${each.key}-nic"
  resource_group_name = var.azure_resource_group
  location            = var.azure_region

  ip_configuration {
    name                          = "${var.environment}-${each.key}-ip-config"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = var.private_ip_allocation_strategy
    public_ip_address_id          = azurerm_public_ip.ip[each.key].id
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "sga" {
  for_each                  = toset(var.vm_computer_names)
  network_interface_id      = azurerm_network_interface.nic[each.key].id
  network_security_group_id = azurerm_network_security_group.sg.id
}

# Generate random text for a unique storage account name
resource "random_id" "diag_storage_account_suffix" {
  for_each = toset(var.vm_computer_names)
  keepers = {
    # Generate a new ID only when a new resource group is defined
    resource_group = var.azure_resource_group
  }

  byte_length = 8
}

# Create storage account for boot diagnostics
resource "azurerm_storage_account" "diag_storage_accounts" {
  for_each                 = toset(var.vm_computer_names)
  name                     = "diag${random_id.diag_storage_account_suffix[each.key].hex}"
  resource_group_name      = var.azure_resource_group
  location                 = var.azure_region
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

// ----------------------------------------------------------------------------
// Virtual machine
// ----------------------------------------------------------------------------
resource "azurerm_windows_virtual_machine" "vm" {
  for_each            = toset(var.vm_computer_names)
  name                = "${each.key}.${var.dns_zone}"
  computer_name       = each.key
  resource_group_name = var.azure_resource_group
  location            = var.azure_region
  size                = var.vm_instance_type
  admin_username      = var.vm_admin_user
  admin_password      = random_password.vm_admin_password.result

  network_interface_ids = [
    azurerm_network_interface.nic[each.key].id,
  ]

  os_disk {
    caching              = var.vm_disk_storage_caching
    storage_account_type = var.vm_disk_storage_type
    disk_size_gb         = var.vm_volume_size
  }

  source_image_reference {
    publisher = var.vm_image_publisher
    offer     = var.vm_image_offer
    sku       = var.vm_image_sku
    version   = var.vm_image_version
  }

  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.diag_storage_accounts[each.key].primary_blob_endpoint
  }

  identity {
    type = "SystemAssigned, UserAssigned"
    identity_ids = [
      azurerm_user_assigned_identity.app_config_access.id,
      azurerm_user_assigned_identity.key_vault_access.id,
      azurerm_user_assigned_identity.dns_zone_access.id
    ]
  }

  tags = {
    Environment = var.environment
  }
}

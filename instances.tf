resource "random_password" "vm_admin_password" {
  length      = 20
  min_lower   = 1
  min_upper   = 1
  min_numeric = 1
  min_special = 1
  special     = true
}

# Create public IPs
resource "azurerm_public_ip" "bots" {
    count               = var.vm_count
    name                = "${var.environment}-public-ip-${count.index+1}"
    resource_group_name = var.azure_resource_group
    location            = var.azure_region
    allocation_method   = var.public_ip_allocation_strategy

    tags = {
        Name        = "${var.environment}-public-ip"
        Environment = var.environment
    }
}


// ----------------------------------------------------------------------------
// Security group is shared between all virtual machines
// ----------------------------------------------------------------------------
resource "azurerm_network_security_group" "bots" {
    name                = "${var.environment}-sg"
    resource_group_name = var.azure_resource_group
    location            = var.azure_region

    dynamic "security_rule" {
        for_each    = var.vm_security_rules
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
        Name        = "${var.environment}-sg"
        Environment = var.environment
    }

    lifecycle {
        create_before_destroy = true
    }
}

# Create network interface
resource "azurerm_network_interface" "bots" {
    count               = var.vm_count
    name                = "${var.environment}-nic-${count.index+1}"
    resource_group_name = var.azure_resource_group
    location            = var.azure_region

    ip_configuration {
        name                          = "${var.environment}-ip-${count.index+1}"
        subnet_id                     = azurerm_subnet.bots.id
        private_ip_address_allocation = var.private_ip_allocation_strategy
        public_ip_address_id          = azurerm_public_ip.bots[count.index].id
    }

    lifecycle {
        create_before_destroy = true
    }
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "bots" {
    count               = var.vm_count
    network_interface_id      = azurerm_network_interface.bots[count.index].id
    network_security_group_id = azurerm_network_security_group.bots.id
}

# Generate random text for a unique storage account name
resource "random_id" "diag_storage_account_suffix" {
  count               = var.vm_count
  keepers = {
    # Generate a new ID only when a new resource group is defined
    resource_group = var.azure_resource_group
  }

  byte_length = 8
}

# Create storage account for boot diagnostics
resource "azurerm_storage_account" "diag_storage_accounts" {
  count               = var.vm_count
  name                = "diag${random_id.diag_storage_account_suffix[count.index].hex}"
  resource_group_name = var.azure_resource_group
  location            = var.azure_region
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

// ----------------------------------------------------------------------------
// Virtual machine
// ----------------------------------------------------------------------------
resource "azurerm_windows_virtual_machine" "bots" {
    count               = var.vm_count
    name                = "${var.vm_computer_name_prefix}${format("%02s", count.index+1)}"
    computer_name       = "${var.vm_computer_name_prefix}${format("%02s", count.index+1)}"
    resource_group_name = var.azure_resource_group
    location            = var.azure_region
    size                = var.vm_instance_type
    admin_username      = var.vm_admin_user
    admin_password      = random_password.vm_admin_password.result

    network_interface_ids = [
        azurerm_network_interface.bots[count.index].id,
    ]

    os_disk {
        name                 = "OsDisk"
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
        storage_account_uri = azurerm_storage_account.diag_storage_accounts[count.index].primary_blob_endpoint
    }

    identity {
        type = "SystemAssigned, UserAssigned"
        identity_ids = [azurerm_user_assigned_identity.app_config_access.id]
    }

    tags = {
        Environment = var.environment
    }
}
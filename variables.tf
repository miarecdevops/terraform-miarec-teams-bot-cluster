
variable "environment" {
  type        = string
  description = "Name of environment (all tags will start with this name)."
}

variable "azure_region" {
  type        = string
  description = "Location where resources and dependencies are going to be deployed"
  default     = "East US"
}

variable "azure_resource_group" {
  type        = string
  description = "Existing Resource Group, where all the resources will be provisioned"
}

variable "azure_app_config_name" {
  type        = string
  description = "Name of the App Configuration endpoint (will be created)"
}

variable "azure_key_vault_name" {
  type        = string
  description = "Name of the Key Vault (will be created)"
}


variable "vm_computer_name_prefix" {
  type = string
  description = "A prefix for generated computer names for VMs. The suffix is an instance index, like (1, 2). Note comupters names can be most 15 characters"
  default = "bot"
}


variable "vm_admin_user" {
  type        = string
  description = "Username that will be set for provisioned instances."
  default     = "botadmin"
}

variable "vm_admin_password" {
  type        = string
  description = "Password for admin user. If not provided, a password will be randomly generated."
  default     = null
}

variable "vm_count" {
  type        = number
  description = "A number of VMs in a cluster"
  default     = 1
}

variable "vm_instance_type" {
  type        = string
  default     = "Standard_B4ms"
  description = "Instace Size of VM. For more information please go to https://docs.microsoft.com/en-us/azure/virtual-machines/sizes"
}

variable "vm_volume_size" {
  type        = number
  description = "Disk size in GB"
  default     = 128
}

variable "vm_disk_storage_type" {
  type        = string
  description = "The Type of Storage Account which should back this the Internal OS Disk. Possible values are Standard_LRS, StandardSSD_LRS, Premium_LRS, StandardSSD_ZRS and Premium_ZRS"
  default     = "Premium_LRS"
}

variable "vm_disk_storage_caching" {
  type        = string
  description = "The Type of Caching which should be used for the Internal OS Disk. Possible values are None, ReadOnly and ReadWrite."
  default     = "ReadWrite"
}


variable "vm_security_rules" {
  default = [
    {
        name                       = "http"
        priority                   = 100
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "80"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    },
    {
        name                       = "https"
        priority                   = 101
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "443"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }
  ]
  description = "Rules that will be used to allow or deny inbound/outbound traffic from/to Azure Resource"
  type        = list(map(any))
}


# --------------------------------------------
# Azure Application Gateway
# --------------------------------------------

variable "appgateway_public_ip_allocation_strategy" {
  type        = string
  description = "The allocation method used for the Public IP Address. Possible values are Dynamic and Static"
  default     = "Dynamic"
}


variable "app_gateway_role" {
  type        = string
  description = "role description"
  default     = "application_gateway"
}


# --------------------------------------------
# Networking
# --------------------------------------------

variable "virtual_network_cidr" {
  type        = string
  description = "The address space that is used by the virtual network."
  default     = "10.0.0.0/16"
}

variable "virtual_vm_subnet_cidr" {
  type        = string
  description = "The address space that is used for the subnet of MiaRec deployment"
  default     = "10.0.0.0/24"
}

variable "virtual_appgateway_subnet_cidr" {
  type        = string
  description = "The address space that is used for the Application Gateway. By requirement this subnet can be only used by Azure Application Gateway"
  default     = "10.0.3.0/24"
}

variable "private_ip_allocation_strategy" {
  type        = string
  description = "The allocation method used for the Private IP Address. Possible values are Dynamic and Static"
  default     = "Dynamic"
}

variable "public_ip_allocation_strategy" {
  type        = string
  description = "The allocation method used for the Public IP Address. Possible values are Dynamic and Static"
  default     = "Static"
}


# --------------------------------------------
# OS Source Image
# --------------------------------------------
variable "vm_image_publisher" {
  type        = string
  description = "The organization that created the image"
  default     = "MicrosoftWindowsServer"
}

variable "vm_image_offer" {
  type        = string
  description = "The name of a group of related images created by a publisher"
  default     = "WindowsServer"
}

variable "vm_image_sku" {
  type        = string
  description = "An instance of an offer, such as a major release of a distribution"
  default     = "2022-datacenter-azure-edition"
}

variable "vm_image_version" {
  type        = string
  description = "The version number of an image SKU"
  default     = "latest"
}

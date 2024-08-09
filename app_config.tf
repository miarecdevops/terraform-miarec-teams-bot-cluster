resource "azurerm_app_configuration" "app_config" {
  name                = var.azure_app_config_name
  resource_group_name = var.azure_resource_group
  location            = var.azure_region
}

# Identity for VMs to access App Config
resource "azurerm_user_assigned_identity" "app_config_access" {
  name                = "${var.environment}-app-config-access"
  resource_group_name = var.azure_resource_group
  location            = var.azure_region
}

resource "azurerm_role_assignment" "app_config_data_reader" {
  scope                = azurerm_app_configuration.app_config.id
  role_definition_name = "App Configuration Data Reader"
  principal_id         = azurerm_user_assigned_identity.app_config_access.principal_id
}

resource "azurerm_app_configuration_key" "siprec_host" {
  configuration_store_id = azurerm_app_configuration.app_config.id
  key                    = "AppSettings:SipRecHost"
  value                  = var.siprec_host
}

resource "azurerm_app_configuration_key" "siprec_port" {
  configuration_store_id = azurerm_app_configuration.app_config.id
  key                    = "AppSettings:SipRecPort"
  value                  = var.siprec_port
}

resource "azurerm_app_configuration_key" "siprec_proto" {
  configuration_store_id = azurerm_app_configuration.app_config.id
  key                    = "AppSettings:SipRecProtocol"
  value                  = var.siprec_protocol
}
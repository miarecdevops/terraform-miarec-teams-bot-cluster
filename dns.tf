data "azurerm_dns_zone" "dns_zone" {
  name                = var.dns_zone
  resource_group_name = var.azure_resource_group
}

resource "azurerm_dns_a_record" "a_record" {
  for_each            = toset(var.vm_computer_names)
  name                = each.key
  zone_name           = var.dns_zone
  resource_group_name = var.azure_resource_group
  ttl                 = 300
  # records             = [azurerm_public_ip.ip[each.key].id]
  target_resource_id  = azurerm_public_ip.ip[each.key].id
}

# Identity for VMs to issue DNS Challenge requests for LetsEncrypt
resource "azurerm_user_assigned_identity" "dns_zone_access" {
  name                = "${var.environment}-dns-zone-access"
  resource_group_name = var.azure_resource_group
  location            = var.azure_region
}

resource "azurerm_role_assignment" "dns_zone_reader" {
  scope                = data.azurerm_dns_zone.dns_zone.id
  role_definition_name = "Reader"
  principal_id         = azurerm_user_assigned_identity.dns_zone_access.principal_id
}


resource "azurerm_role_assignment" "dns_zone_contributor" {
  scope                = data.azurerm_dns_zone.dns_zone.id
  role_definition_name = "DNS Zone Contributor"
  principal_id         = azurerm_user_assigned_identity.dns_zone_access.principal_id
}
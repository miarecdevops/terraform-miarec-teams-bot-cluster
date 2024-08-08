
resource "azurerm_key_vault" "vault" {
  name                       = var.azure_key_vault_name

  resource_group_name = var.azure_resource_group
  location            = var.azure_region

  tenant_id                  = data.azurerm_client_config.current.tenant_id

  sku_name                   = "standard"

  soft_delete_retention_days = 7
  purge_protection_enabled   = true
}

# Here, we had to make a trick of reading back the virtual machine information and SystemAssigned identity
# Otherwise, the "azurerm_key_valut_access_policy" cannot be created with error:
#    The argument "object_id" is required, but no definition was found.
data "azurerm_virtual_machine" "bots" {
    count = var.vm_count
    name = azurerm_windows_virtual_machine.bots[count.index].name
    resource_group_name = var.azure_resource_group
}

# Grant virtual machines to read secrets from Key Vault
resource "azurerm_key_vault_access_policy" "key_vault_access" {
  count               = var.vm_count
  # for_each = toset(flatten(azurerm_windows_virtual_machine.bots[*].identity[0].principal_id))
  
  key_vault_id = azurerm_key_vault.vault.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  # object_id    = each.value
  object_id    = data.azurerm_virtual_machine.bots[count.index].identity[0].principal_id

  key_permissions    = ["Get", "UnwrapKey", "WrapKey"]
  secret_permissions = ["Get"]

  depends_on = [
    azurerm_windows_virtual_machine.bots,
  ]
}
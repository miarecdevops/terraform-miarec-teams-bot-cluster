
resource "azurerm_key_vault" "vault" {
  name = var.azure_key_vault_name

  resource_group_name = var.azure_resource_group
  location            = var.azure_region

  tenant_id = data.azurerm_client_config.current.tenant_id

  sku_name = "standard"

  soft_delete_retention_days = 7
  purge_protection_enabled   = true
}

# Identity for VMs to access Key Valut
resource "azurerm_user_assigned_identity" "key_vault_access" {
  name                = "${var.environment}-key-vault-access"
  resource_group_name = var.azure_resource_group
  location            = var.azure_region
}

resource "azurerm_role_assignment" "key_vault_secrets_user" {
  scope                = azurerm_key_vault.vault.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_user_assigned_identity.key_vault_access.principal_id
}
data "template_file" "install_script" {
  for_each = toset(var.vm_computer_names)
  template = file("files/InstallMiaRecBot.ps1.tftpl")
  vars = {
    traefik_download_url = var.traefik_download_url
    bot_download_url     = var.bot_download_url
    install_dir          = var.install_dir

    azure_tenant_id      = data.azurerm_client_config.current.tenant_id
    azure_resource_group = var.azure_resource_group

    bot_fqdn             = "${each.key}.${var.dns_zone}"

    letsencrypt_email    = var.letsencrypt_email

    key_valut_name       = azurerm_key_vault.vault.name
    app_config_endpoint  = azurerm_app_configuration.app_config.name
  }
}

resource "azurerm_virtual_machine_extension" "install_script" {
  for_each           = toset(var.vm_computer_names)
  name               = "${var.environment}-${each.key}-install-script"
  virtual_machine_id = azurerm_windows_virtual_machine.vm[each.key].id

  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"

  settings = <<SETTINGS
    {
      "commandToExecute": "powershell -command \"[System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String('${base64encode(data.template_file.install_script[each.key].rendered)}')) | Out-File -filepath Install.ps1\" && powershell -ExecutionPolicy Unrestricted -NoProfile -NonInteractive ./Install.ps1"
    }
    SETTINGS
}
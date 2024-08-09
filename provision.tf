locals {
  install_script = base64encode(templatefile("files/InstallMiaRecBot.ps1.tftpl", {
    traefik_download_url = var.traefik_download_url,
    bot_download_url     = var.bot_download_url,
    install_dir          = var.install_dir,
  }))
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
      "commandToExecute": "powershell -command \"[System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String('${local.install_script}')) | Out-File -filepath ./Install.ps1\" &&  powershell -ExecutionPolicy Unrestricted -NoProfile -NonInteractive Install.ps1"
    }
    SETTINGS
}
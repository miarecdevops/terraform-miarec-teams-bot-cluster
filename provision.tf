locals {
  install_script = textencodebase64(templatefile("files/InstallMiaRecBot.ps1.tftpl", {
    traefik_download_url = var.traefik_download_url,
    bot_download_url = var.bot_download_url,
    install_dir = var.install_dir,
  }), "UTF-16LE")
}

resource "azurerm_virtual_machine_extension" "install_script" {
    count                = var.vm_count
    name                 = "${var.environment}-install-${count.index}"
    virtual_machine_id = azurerm_windows_virtual_machine.bots[count.index].id

    publisher            = "Microsoft.Compute"
    type                 = "CustomScriptExtension"
    type_handler_version = "1.9"

    settings = <<SETTINGS
    {
      "commandToExecute": "powershell -ExecutionPolicy Unrestricted -encodedCommand ${local.install_script}"
    }
    SETTINGS
}
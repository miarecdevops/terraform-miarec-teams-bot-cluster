# output "vm_public_ip_address" {
#  description = "VM instances - Public IP"
#  value       = module.bastion[*].vm_public_ip_address
#}

output "admin_password" {
  description = "VM admin password"
  value       = random_password.vm_admin_password.result
  sensitive   = true
}

output "vm_public_ips" {
  value = [
    for k, v in azurerm_public_ip.ip :
    v.ip_address
  ]
}

output "vm_url" {
  value = [
    for k, v in azurerm_windows_virtual_machine.vm :
    "https://${v.name}/dashboard/"
  ]
}

output "calling_url" {
  value = "https://${var.dns_shared_address}/calling"
}


output "load_balancer_ip_address" {
  value = azurerm_public_ip.lb_public_ip.ip_address
}

output "load_balancer_dns" {
  value = var.dns_shared_address
}

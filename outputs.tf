# output "vm_public_ip_address" {
#  description = "VM instances - Public IP"
#  value       = module.bastion[*].vm_public_ip_address
#}

output "admin_password" {
  description = "VM admin password"
  value       = random_password.vm_admin_password.result
  sensitive   = true
}
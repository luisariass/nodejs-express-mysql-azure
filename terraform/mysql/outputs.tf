# En terraform/mysql/outputs.tf (o al final de mysql-infrastructure.tf)

output "mysql_private_ip" {
  description = "Private IP address of the MySQL VM"
  value       = azurerm_network_interface.mysql_nic.private_ip_address
}

output "mysql_public_ip" {
  description = "Public IP address of the MySQL VM"
  value       = azurerm_public_ip.mysql_public_ip.ip_address
}
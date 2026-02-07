# Outputs commented out due to wait_for_ip = false
# Uncomment after VMs have IPs, or check IPs in Xen Orchestra

# output "control_node_ip" {
#   value       = xenorchestra_vm.control_node.network[0].ipv4_addresses[0]
#   description = "Control node IP address"
# }

# output "web_ip" {
#   value       = xenorchestra_vm.web.network[0].ipv4_addresses[0]
#   description = "Web server IP address"
# }

# output "db_ip" {
#   value       = xenorchestra_vm.db.network[0].ipv4_addresses[0]
#   description = "Database server IP address"
# }

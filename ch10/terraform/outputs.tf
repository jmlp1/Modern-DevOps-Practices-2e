output "web1_id" {
  description = "Web server 1 VM ID"
  value       = xenorchestra_vm.web1.id
}

output "web2_id" {
  description = "Web server 2 VM ID"
  value       = xenorchestra_vm.web2.id
}

output "db_id" {
  description = "Database server VM ID"
  value       = xenorchestra_vm.db.id
}

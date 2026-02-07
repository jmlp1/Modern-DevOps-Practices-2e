variable "xo_url" {
  type        = string
  description = "Xen Orchestra URL"
  default     = "http://192.168.1.240"
}

variable "xo_username" {
  type        = string
  description = "Xen Orchestra username"
  default     = "admin@admin.net"
}

variable "xo_password" {
  type        = string
  description = "Xen Orchestra password"
  sensitive   = true
}

variable "admin_username" {
  type        = string
  description = "The Linux admin username"
  default     = "ansible"
}

variable "admin_password" {
  type        = string
  description = "The Linux admin password"
  sensitive   = true
}

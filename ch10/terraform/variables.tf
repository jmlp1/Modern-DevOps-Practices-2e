variable "xo_url" {
  description = "URL of Xen Orchestra"
  type        = string
}

variable "xo_username" {
  description = "Xen Orchestra username"
  type        = string
}

variable "xo_password" {
  description = "Xen Orchestra password"
  type        = string
  sensitive   = true
}

variable "admin_username" {
  description = "VM admin username"
  type        = string
}

variable "admin_password" {
  description = "VM admin password"
  type        = string
  sensitive   = true
}

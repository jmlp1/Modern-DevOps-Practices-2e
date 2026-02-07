terraform {
  required_providers {
    xenorchestra = {
      source  = "terra-farm/xenorchestra"
      version = "~> 0.25.0"
    }
  }
}

provider "xenorchestra" {
  url      = var.xo_url
  username = var.xo_username
  password = var.xo_password
  insecure = true  # Set to false if using valid SSL cert
  
}

# Data sources
data "xenorchestra_template" "ubuntu_template" {
  name_label = "Ubuntu_24.04"
}

data "xenorchestra_network" "net" {
  name_label = "VM Network eth1"
}

data "xenorchestra_sr" "local_storage" {
  name_label = "Local storage"
}

# Web Server 1
resource "xenorchestra_vm" "web1" {
  name_label        = "web1"
  template          = data.xenorchestra_template.ubuntu_template.id
  cpus              = 2
  memory_max        = 4294967296  # 4GB in bytes
  hvm_boot_firmware = "uefi"
  wait_for_ip       = false

  network {
    network_id = data.xenorchestra_network.net.id
  }

  disk {
    sr_id      = data.xenorchestra_sr.local_storage.id
    name_label = "web1-root"
    size       = 42949672960  # 40GB in bytes
  }

  tags = ["lamp", "web"]
}

# Web Server 2
resource "xenorchestra_vm" "web2" {
  name_label        = "web2"
  template          = data.xenorchestra_template.ubuntu_template.id
  cpus              = 2
  memory_max        = 4294967296  # 4GB in bytes
  hvm_boot_firmware = "uefi"
  wait_for_ip       = false

  network {
    network_id = data.xenorchestra_network.net.id
  }

  disk {
    sr_id      = data.xenorchestra_sr.local_storage.id
    name_label = "web2-root"
    size       = 42949672960  # 40GB in bytes
  }

  tags = ["lamp", "web"]
}

# Database Server
resource "xenorchestra_vm" "db" {
  name_label        = "db"
  template          = data.xenorchestra_template.ubuntu_template.id
  cpus              = 2
  memory_max        = 4294967296  # 4GB in bytes
  hvm_boot_firmware = "uefi"
  wait_for_ip       = false

  network {
    network_id = data.xenorchestra_network.net.id
  }

  disk {
    sr_id      = data.xenorchestra_sr.local_storage.id
    name_label = "db-root"
    size       = 42949672960  # 40GB in bytes
  }

  tags = ["lamp", "db"]
}

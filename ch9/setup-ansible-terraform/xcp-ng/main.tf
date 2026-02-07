terraform {
  required_providers {
    xenorchestra = {
      source = "terra-farm/xenorchestra"
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

data "xenorchestra_template" "ubuntu_template" {
  name_label = "Ubuntu_24.04"
}

data "xenorchestra_network" "net" {
  name_label = "VM Network eth1"
}

data "xenorchestra_sr" "local_storage" {
  name_label = "Local storage"
}

# Control Node VM
resource "xenorchestra_vm" "control_node" {
  name_label       = "ansible-control-node"
  template         = data.xenorchestra_template.ubuntu_template.id

  cpus   = 2
  memory_max = 4294967296  # 4GB in bytes

  # Explicitly set firmware to match your working manual VM
  hvm_boot_firmware = "uefi"
  wait_for_ip       = false # Prevents Terraform from hanging indefinitely if guest tools are slow

  network {
    network_id = data.xenorchestra_network.net.id
  }

  disk {
    sr_id      = data.xenorchestra_sr.local_storage.id
    name_label = "ansible-control-node-root"
    size       = 42949672960  # 40GB in bytes
  }

  depends_on = [
    xenorchestra_vm.web,
    xenorchestra_vm.db
  ]

  tags = ["ansible", "control-node"]
}

# Web VM
resource "xenorchestra_vm" "web" {
  name_label = "web"
  template   = data.xenorchestra_template.ubuntu_template.id

  cpus   = 2
  memory_max = 4294967296  # 4GB in bytes

  # Explicitly set firmware to match your working manual VM
  hvm_boot_firmware = "uefi"
  wait_for_ip       = false

  network {
    network_id = data.xenorchestra_network.net.id
  }

  disk {
    sr_id      = data.xenorchestra_sr.local_storage.id
    name_label = "web-root"
    size       = 42949672960  # 40GB in bytes
  }

  tags = ["ansible", "web"]
}

# DB VM
resource "xenorchestra_vm" "db" {
  name_label = "db"
  template   = data.xenorchestra_template.ubuntu_template.id

  cpus   = 2
  memory_max = 4294967296  # 4GB in bytes

  # Explicitly set firmware to match your working manual VM
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

  tags = ["ansible", "db"]
}

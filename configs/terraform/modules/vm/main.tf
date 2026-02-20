terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.71"
    }
  }
}

resource "proxmox_virtual_environment_vm" "vm" {
  node_name = var.target_node
  vm_id     = var.vmid
  name      = var.name

  # Description and tags
  description = var.description
  tags        = var.tags != "" ? split(";", var.tags) : []

  # Boot settings
  started = var.start_on_create
  on_boot = var.onboot

  # Clone settings (if using template)
  dynamic "clone" {
    for_each = var.clone_template != "" ? [1] : []
    content {
      vm_id = var.clone_template_id
      full  = var.full_clone
    }
  }

  # Agent
  agent {
    enabled = var.qemu_agent == 1
  }

  # CPU
  cpu {
    cores   = var.cores
    sockets = var.sockets
    type    = var.cpu_type
  }

  # Memory
  memory {
    dedicated = var.memory
  }

  # Disks
  dynamic "disk" {
    for_each = var.disks
    content {
      interface    = disk.value.type
      datastore_id = disk.value.storage
      size         = parseint(replace(disk.value.size, "G", ""), 10)
      file_format  = lookup(disk.value, "format", "raw")
      ssd          = lookup(disk.value, "ssd", false)
      discard      = lookup(disk.value, "discard", false) ? "on" : "ignore"
      iothread     = lookup(disk.value, "iothread", false)
    }
  }

  # Network interfaces
  dynamic "network_device" {
    for_each = var.networks
    content {
      model   = network_device.value.model
      bridge  = network_device.value.bridge
      vlan_id = lookup(network_device.value, "vlan_tag", null)
    }
  }

  # Cloud-init initialization
  dynamic "initialization" {
    for_each = var.use_cloud_init ? [1] : []
    content {
      ip_config {
        ipv4 {
          address = length(split(",", var.ip_config)) > 0 ? split(",", split("=", var.ip_config)[1])[0] : "dhcp"
          gateway = length(split(",", var.ip_config)) > 1 ? split("=", split(",", var.ip_config)[1])[1] : null
        }
      }

      dns {
        server = var.nameserver
      }

      user_account {
        username = var.cloud_init_user
        password = var.cloud_init_password
        keys     = var.ssh_public_keys != "" ? [var.ssh_public_keys] : []
      }
    }
  }

  # BIOS
  bios = var.bios

  # SCSI hardware
  scsi_hardware = var.scsihw

  # Operating system type
  operating_system {
    type = var.os_type == "cloud-init" ? "l26" : "other"
  }
}

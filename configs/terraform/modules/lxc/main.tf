terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.71"
    }
  }
}

resource "proxmox_virtual_environment_container" "container" {
  node_name = var.target_node
  vm_id     = var.vmid

  # Container configuration
  description = var.description
  tags        = var.tags != "" ? split(";", var.tags) : []

  # Boot settings
  started = var.start

  startup {
    order = var.onboot ? 1 : null
  }

  # Operating system
  operating_system {
    template_file_id = var.ostemplate != "" ? var.ostemplate : null
    type             = "ubuntu"
  }

  # Ignore changes to sensitive fields for existing containers
  lifecycle {
    ignore_changes = [
      operating_system[0].template_file_id,
      features,
      initialization,
    ]
  }

  # Resources
  cpu {
    cores = var.cores
  }

  memory {
    dedicated = var.memory
    swap      = var.swap
  }

  # Root filesystem
  disk {
    datastore_id = var.rootfs_storage
    size         = parseint(replace(var.rootfs_size, "G", ""), 10)
  }

  # Network interface
  network_interface {
    name    = var.network_name
    bridge  = var.network_bridge
    enabled = true
  }

  # Initialization (cloud-init like for LXC)
  initialization {
    hostname = var.hostname

    dynamic "ip_config" {
      for_each = var.network_ip != "" ? [1] : []
      content {
        ipv4 {
          address = var.network_ip
          gateway = var.network_gateway
        }
      }
    }

    dynamic "user_account" {
      for_each = var.ssh_public_keys != "" ? [1] : []
      content {
        keys = [var.ssh_public_keys]
      }
    }
  }

  # Features
  features {
    nesting = var.features_nesting
    keyctl  = var.features_keyctl
    fuse    = var.features_fuse
  }

  # Console settings
  console {
    enabled   = true
    type      = "shell"
    tty_count = 2
  }

  # Privilege mode
  unprivileged = var.unprivileged
}

# Session 2.2: Deploying LXC Containers and VMs with Terraform

## Overview

Now that you understand Terraform and Infrastructure as Code principles, it's time to deploy actual infrastructure on your Proxmox cluster.

In this section, you'll:
- Create reusable Terraform modules for LXC containers
- Create a module for virtual machines
- Deploy your Docker host LXC container
- Verify the deployment
- Learn how to use Terraform modules for infrastructure scalability

## LXC vs VMs: Quick Recap

From Session 1, remember:

**LXC Containers:**
- Lightweight, container-based virtualization
- Shares kernel with host
- Fast boot and low resource overhead
- Perfect for microservices, Docker hosts, application servers
- Unprivileged (more secure) by default, but can be privileged

**Virtual Machines:**
- Full OS virtualization (kernel included)
- More resource intensive
- Better isolation
- Perfect for databases, Windows services, exotic OSes
- Full control over the OS

For your Docker host, we'll use an **LXC container** because:
- Fast startup
- Low overhead
- Perfect for running Docker
- Easy to manage with Terraform

## Creating the LXC Module

### Module Purpose

A Terraform module is a reusable collection of configuration. Instead of writing container definitions multiple times, we create one module and use it for all containers.

### Module Structure

```
modules/lxc/
├── main.tf          # Main resource definitions
├── variables.tf     # Input variables
├── outputs.tf       # Output values
└── README.md        # Module documentation
```

### modules/lxc/variables.tf

```hcl
variable "proxmox_node" {
  description = "Proxmox cluster node to deploy container on"
  type        = string
}

variable "vmid" {
  description = "Unique VM ID for the container (100-999)"
  type        = number
  validation {
    condition     = var.vmid >= 100 && var.vmid <= 999
    error_message = "VMID must be between 100 and 999."
  }
}

variable "hostname" {
  description = "Hostname for the container"
  type        = string
  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.hostname))
    error_message = "Hostname must contain only lowercase letters, numbers, and hyphens."
  }
}

variable "description" {
  description = "Container description"
  type        = string
  default     = ""
}

# Resource sizing
variable "cores" {
  description = "Number of CPU cores"
  type        = number
  default     = 2
  validation {
    condition     = var.cores > 0 && var.cores <= 128
    error_message = "Cores must be between 1 and 128."
  }
}

variable "memory" {
  description = "RAM in MB"
  type        = number
  default     = 2048
  validation {
    condition     = var.memory >= 512 && var.memory <= 262144
    error_message = "Memory must be between 512 MB and 256 GB."
  }
}

variable "rootfs_size" {
  description = "Root filesystem size (e.g., '64G', '100G')"
  type        = string
  default     = "20G"
}

# Networking
variable "ipv4_address" {
  description = "IPv4 address with CIDR (e.g., 192.168.10.50/24)"
  type        = string
}

variable "ipv4_gateway" {
  description = "IPv4 gateway address"
  type        = string
}

variable "search_domain" {
  description = "DNS search domain"
  type        = string
  default     = ""
}

variable "nameserver" {
  description = "DNS nameserver IPs (space-separated)"
  type        = string
  default     = "8.8.8.8 8.8.4.4"
}

# OS and Template
variable "ostype" {
  description = "OS type (ubuntu, debian, alpine, etc.)"
  type        = string
  default     = "ubuntu"
}

variable "osversion" {
  description = "OS version (e.g., '22.04' for Ubuntu, '12' for Debian)"
  type        = string
  default     = "22.04"
}

# Container Features
variable "privileged" {
  description = "Run as privileged container (required for Docker)"
  type        = bool
  default     = false
}

variable "nesting" {
  description = "Allow container nesting (required for Docker)"
  type        = bool
  default     = false
}

variable "keyctl" {
  description = "Allow keyctl (required for some Docker operations)"
  type        = bool
  default     = false
}

variable "fuse" {
  description = "Allow FUSE (filesystem in user space)"
  type        = bool
  default     = false
}

# Additional Features
variable "start_on_boot" {
  description = "Start container on boot"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Container tags for organization"
  type        = list(string)
  default     = []
}

variable "timezone" {
  description = "Container timezone"
  type        = string
  default     = "UTC"
}
```

### modules/lxc/main.tf

```hcl
resource "proxmox_lxc_container" "container" {
  vmid         = var.vmid
  target_node  = var.proxmox_node
  hostname     = var.hostname
  description  = var.description
  ostype       = var.ostype
  osversion    = var.osversion

  # Resource allocation
  cores  = var.cores
  memory = var.memory

  # Storage
  rootfs {
    storage = "local-lvm"
    size    = var.rootfs_size
  }

  # Networking - DHCP disabled, using static IP
  network {
    name   = "eth0"
    hwaddr = ""
    ip     = var.ipv4_address
    gw     = var.ipv4_gateway
  }

  # DNS configuration
  nameserver = var.nameserver
  searchdomain = var.search_domain

  # Container features for Docker support
  features {
    nesting = var.nesting
    keyctl  = var.keyctl
    fuse    = var.fuse
  }

  # Security and startup
  privileged      = var.privileged
  start_on_boot   = var.start_on_boot

  # Tags
  tags = join(";", concat(var.tags, ["terraform"]))

  # Timezone
  timezone = var.timezone

  # Prevent Terraform from updating the container if it's already created
  lifecycle {
    ignore_changes = [
      features,  # Features may be applied differently
    ]
  }
}

# Wait for container to be running
resource "time_sleep" "wait_for_container" {
  depends_on      = [proxmox_lxc_container.container]
  create_duration = "10s"
}
```

### modules/lxc/outputs.tf

```hcl
output "vmid" {
  description = "Container VMID"
  value       = proxmox_lxc_container.container.vmid
}

output "hostname" {
  description = "Container hostname"
  value       = proxmox_lxc_container.container.hostname
}

output "ipv4_address" {
  description = "Container IPv4 address"
  value       = var.ipv4_address
}

output "proxmox_node" {
  description = "Proxmox node hosting the container"
  value       = var.proxmox_node
}

output "status" {
  description = "Container resource ID"
  value       = proxmox_lxc_container.container.id
}
```

## Creating the VM Module

### Module Structure

```
modules/vm/
├── main.tf
├── variables.tf
├── outputs.tf
└── README.md
```

### modules/vm/variables.tf

```hcl
variable "proxmox_node" {
  description = "Proxmox cluster node to deploy VM on"
  type        = string
}

variable "vmid" {
  description = "Unique VM ID (100-999)"
  type        = number
  validation {
    condition     = var.vmid >= 100 && var.vmid <= 999
    error_message = "VMID must be between 100 and 999."
  }
}

variable "name" {
  description = "Virtual machine name"
  type        = string
  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.name))
    error_message = "VM name must contain only lowercase letters, numbers, and hyphens."
  }
}

variable "description" {
  description = "VM description"
  type        = string
  default     = ""
}

# Clone settings
variable "clone" {
  description = "Template VM ID or name to clone from"
  type        = string
  default     = "ubuntu-22-04-cloudinit-template"
}

# Resource sizing
variable "cores" {
  description = "Number of CPU cores"
  type        = number
  default     = 4
  validation {
    condition     = var.cores > 0 && var.cores <= 128
    error_message = "Cores must be between 1 and 128."
  }
}

variable "sockets" {
  description = "Number of CPU sockets"
  type        = number
  default     = 1
}

variable "memory" {
  description = "RAM in MB"
  type        = number
  default     = 4096
  validation {
    condition     = var.memory >= 512 && var.memory <= 262144
    error_message = "Memory must be between 512 MB and 256 GB."
  }
}

# Storage
variable "scsi_hardware" {
  description = "SCSI hardware type"
  type        = string
  default     = "virtio-scsi-pci"
}

variable "disks" {
  description = "List of disk definitions"
  type = list(object({
    datastore = string
    size      = string
    index     = number
  }))
  default = []
}

# Networking
variable "ipv4_address" {
  description = "IPv4 address with CIDR (e.g., 192.168.10.100/24)"
  type        = string
}

variable "ipv4_gateway" {
  description = "IPv4 gateway address"
  type        = string
}

variable "nameserver" {
  description = "DNS nameserver IPs (space-separated)"
  type        = string
  default     = "8.8.8.8 8.8.4.4"
}

variable "search_domain" {
  description = "DNS search domain"
  type        = string
  default     = ""
}

# Cloud-init
variable "ciuser" {
  description = "Cloud-init username"
  type        = string
  default     = "ubuntu"
}

variable "cipassword" {
  description = "Cloud-init password (hashed or plain)"
  type        = string
  sensitive   = true
  default     = "ubuntu"
}

variable "ssh_keys" {
  description = "SSH public keys to add to cloud-init"
  type        = string
  default     = ""
}

# Startup
variable "start_on_boot" {
  description = "Start VM on boot"
  type        = bool
  default     = true
}

variable "tags" {
  description = "VM tags"
  type        = list(string)
  default     = []
}

variable "timezone" {
  description = "VM timezone"
  type        = string
  default     = "UTC"
}
```

### modules/vm/main.tf

```hcl
resource "proxmox_virtual_environment_vm" "vm" {
  vm_id      = var.vmid
  node_name  = var.proxmox_node
  name       = var.name
  description = var.description

  # Clone from template
  clone {
    vm_id = var.clone
  }

  # CPU configuration
  cpu {
    cores   = var.cores
    sockets = var.sockets
  }

  # Memory
  memory {
    dedicated = var.memory
  }

  # SCSI controller for disks
  scsi_hardware = var.scsi_hardware

  # Additional disks
  dynamic "disk" {
    for_each = var.disks
    content {
      datastore_id = disk.value.datastore
      size         = disk.value.size
      interface    = "scsi${disk.value.index}"
    }
  }

  # Network interface
  network_device {
    bridge   = "vmbr0"
    model    = "virtio"
  }

  # Cloud-init configuration
  initialization {
    datastore_id = "local-lvm"

    user_account {
      username = var.ciuser
      password = var.cipassword
      keys     = [var.ssh_keys]
    }

    network_data_type = "cloud-config"
    network_config {
      ipv4 {
        address = [var.ipv4_address]
        gateway = var.ipv4_gateway
      }

      nameserver {
        nameservers = split(" ", var.nameserver)
        search      = [var.search_domain]
      }
    }
  }

  # Boot settings
  on_boot = var.start_on_boot

  # Tags
  tags = concat(var.tags, ["terraform"])
}
```

### modules/vm/outputs.tf

```hcl
output "vmid" {
  description = "VM ID"
  value       = proxmox_virtual_environment_vm.vm.vm_id
}

output "name" {
  description = "VM name"
  value       = proxmox_virtual_environment_vm.vm.name
}

output "ipv4_address" {
  description = "VM IPv4 address"
  value       = var.ipv4_address
}

output "proxmox_node" {
  description = "Proxmox node hosting the VM"
  value       = var.proxmox_node
}
```

## Deploying the Docker Host LXC Container

Now let's use the LXC module to deploy your Docker host container.

### main.tf

Create your main configuration file that uses the LXC module:

```hcl
module "docker_host" {
  source = "./modules/lxc"

  # Basic configuration
  proxmox_node = var.proxmox_cluster_node
  vmid         = 100
  hostname     = "docker-host"
  description  = "Docker host container - Session 2"

  # Resource sizing
  cores      = 4
  memory     = 8192      # 8GB
  rootfs_size = "64G"

  # Networking
  ipv4_address  = "192.168.10.50/24"
  ipv4_gateway  = var.gateway
  nameserver    = "1.1.1.1 1.0.0.1"  # Cloudflare DNS
  search_domain = ""

  # OS
  ostype    = "ubuntu"
  osversion = "22.04"

  # Docker requirements
  privileged = true      # Required for Docker
  nesting    = true      # Allow container nesting
  keyctl     = true      # Required for Docker operations
  fuse       = true      # Allow FUSE (for overlayfs)

  # Boot settings
  start_on_boot = true

  # Tags for organization
  tags     = ["docker", "services", "session2"]
  timezone = var.timezone
}

# Output the Docker host details
output "docker_host_info" {
  description = "Docker host container information"
  value = {
    vmid     = module.docker_host.vmid
    hostname = module.docker_host.hostname
    ip       = module.docker_host.ipv4_address
    node     = module.docker_host.proxmox_node
  }
}
```

### Deploy the Container

```bash
# Navigate to your Terraform directory
cd ~/homelab/proxmox-terraform

# Copy the example tfvars if you haven't already
cp terraform.tfvars.example terraform.tfvars

# Edit with your API token
nano terraform.tfvars

# Initialize Terraform
terraform init

# Review what will be created
terraform plan

# Expected output:
# Terraform will perform the following actions:
#
#   # module.docker_host.proxmox_lxc_container.container will be created
#   + resource "proxmox_lxc_container" "container" {
#       + hostname    = "docker-host"
#       + vmid        = 100
#       + cores       = 4
#       + memory      = 8192
#       + rootfs_size = "64G"
#       # ... more attributes ...
#     }
#
# Plan: 1 to add, 0 to change, 0 to destroy.

# Apply the configuration
terraform apply

# Confirm with 'yes' when prompted
```

### Verify the Deployment

After `terraform apply` completes successfully:

```bash
# Check Terraform state
terraform state show module.docker_host

# Check outputs
terraform output docker_host_info
```

### Verify in Proxmox Web UI

1. Open https://192.168.10.129:8006 in your browser
2. Log in with your Proxmox credentials
3. Navigate to **prx01** > **100 (docker-host)**
4. Verify:
   - Status shows "running"
   - Configuration shows 4 cores, 8GB RAM, 64GB storage
   - Network shows IP 192.168.10.50

## Accessing Your Docker Host Container

### SSH Into the Container

```bash
# Find the IP address (from Terraform output or Proxmox UI)
# Then SSH in
ssh root@192.168.10.50

# First login prompt for password
# Default Proxmox template password may be 'proxmox'
# Or connect via Proxmox console
```

### Via Proxmox Console

1. In Proxmox UI, click the container **100 (docker-host)**
2. Click **Console** tab
3. Click **xterm.js** to open web console
4. Log in as root

### Update the System

```bash
apt update
apt upgrade -y
```

## Deploying a Virtual Machine (Optional)

If you want to deploy a VM as well, here's an example:

### main.tf (VM example)

```hcl
module "database_server" {
  source = "./modules/vm"

  proxmox_node = var.proxmox_cluster_node
  vmid         = 101
  name         = "database-server"
  description  = "PostgreSQL database server"

  # Clone from a Ubuntu cloud-init template
  clone = "ubuntu-22-04-cloudinit-template"

  # Resource sizing
  cores   = 4
  sockets = 1
  memory  = 8192

  # Networking
  ipv4_address  = "192.168.10.51/24"
  ipv4_gateway  = var.gateway
  nameserver    = "1.1.1.1 1.0.0.1"

  # Cloud-init
  ciuser = "ubuntu"
  cipassword = "YourPasswordHere"  # Consider using variables with sensitive=true

  # Boot settings
  start_on_boot = true
  tags          = ["database", "session2"]
  timezone      = var.timezone
}
```

## Terraform Import (For Existing Resources)

If you have resources already created in Proxmox that you want to manage with Terraform:

```bash
# Import an existing container with VMID 102
terraform import 'module.docker_host.proxmox_lxc_container.container' 102

# After import, add the resource to your Terraform code
# and update the configuration to match the actual resource
```

## Managing Multiple Containers

Use Terraform variables to deploy multiple containers easily:

```hcl
# variables.tf
variable "containers" {
  description = "Map of containers to deploy"
  type = map(object({
    vmid          = number
    hostname      = string
    cores         = number
    memory        = number
    ipv4_address  = string
    privileged    = bool
    nesting       = bool
  }))
}

# terraform.tfvars
containers = {
  docker_host = {
    vmid         = 100
    hostname     = "docker-host"
    cores        = 4
    memory       = 8192
    ipv4_address = "192.168.10.50/24"
    privileged   = true
    nesting      = true
  }
  app_server = {
    vmid         = 101
    hostname     = "app-server"
    cores        = 2
    memory       = 4096
    ipv4_address = "192.168.10.51/24"
    privileged   = false
    nesting      = false
  }
}

# main.tf
module "containers" {
  for_each = var.containers

  source = "./modules/lxc"

  proxmox_node  = var.proxmox_cluster_node
  vmid          = each.value.vmid
  hostname      = each.value.hostname
  cores         = each.value.cores
  memory        = each.value.memory
  ipv4_address  = each.value.ipv4_address
  ipv4_gateway  = var.gateway
  privileged    = each.value.privileged
  nesting       = each.value.nesting
  # ... other configuration ...
}
```

## Troubleshooting

### Container Won't Start

```bash
# SSH into Proxmox node and check container logs
pct logs 100

# Check if VMID is already in use
pvesh get /nodes/prx01/lxc
```

### Network Not Working

```bash
# Inside container, check network config
ip addr show
ip route show

# Check DNS
nslookup google.com
```

### Terraform State Out of Sync

```bash
# Refresh state from actual Proxmox
terraform refresh

# Or re-plan to see differences
terraform plan
```

## Next Steps

You now have:
- A Docker host container running on Proxmox
- Understanding of Terraform modules and configuration
- Ability to deploy infrastructure as code

Next, you'll set up Tailscale to securely access your homelab from anywhere, then deploy services with Docker Compose.

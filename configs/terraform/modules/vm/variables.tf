variable "name" {
  description = "Name of the VM"
  type        = string
}

variable "description" {
  description = "Description for the VM"
  type        = string
  default     = ""
}

variable "target_node" {
  description = "Proxmox node to deploy the VM on"
  type        = string
}

variable "vmid" {
  description = "VM ID"
  type        = number
  default     = null
}

variable "clone_template" {
  description = "Name of the template to clone from"
  type        = string
  default     = ""
}

variable "clone_template_id" {
  description = "VM ID of the template to clone from"
  type        = number
  default     = null
}

variable "start_on_create" {
  description = "Whether to start the VM after creation"
  type        = bool
  default     = true
}

variable "use_cloud_init" {
  description = "Whether to use cloud-init"
  type        = bool
  default     = true
}

variable "full_clone" {
  description = "Whether to create a full clone"
  type        = bool
  default     = true
}

variable "onboot" {
  description = "Whether to start the VM on boot"
  type        = bool
  default     = true
}

variable "qemu_agent" {
  description = "Enable QEMU guest agent"
  type        = number
  default     = 1
}

variable "cores" {
  description = "Number of CPU cores"
  type        = number
  default     = 2
}

variable "sockets" {
  description = "Number of CPU sockets"
  type        = number
  default     = 1
}

variable "memory" {
  description = "Amount of RAM in MB"
  type        = number
  default     = 2048
}

variable "cpu_type" {
  description = "CPU type"
  type        = string
  default     = "host"
}

variable "os_type" {
  description = "OS type"
  type        = string
  default     = "cloud-init"
}

variable "bios" {
  description = "BIOS type (seabios or ovmf)"
  type        = string
  default     = "seabios"
}

variable "scsihw" {
  description = "SCSI controller type"
  type        = string
  default     = "virtio-scsi-pci"
}

variable "disks" {
  description = "List of disks to attach to the VM"
  type = list(object({
    type     = string
    storage  = string
    size     = string
    format   = optional(string)
    ssd      = optional(bool)
    discard  = optional(bool)
    iothread = optional(bool)
  }))
  default = [{
    type    = "scsi"
    storage = "local-lvm"
    size    = "20G"
  }]
}

variable "networks" {
  description = "List of network interfaces"
  type = list(object({
    model    = string
    bridge   = string
    vlan_tag = optional(number)
  }))
  default = [{
    model  = "virtio"
    bridge = "vmbr0"
  }]
}

variable "ip_config" {
  description = "IP configuration (e.g., ip=192.168.10.100/24,gw=192.168.10.1)"
  type        = string
  default     = "ip=dhcp"
}

variable "nameserver" {
  description = "DNS nameserver"
  type        = string
  default     = "192.168.10.1"
}

variable "cloud_init_user" {
  description = "Cloud-init username"
  type        = string
  default     = ""
}

variable "cloud_init_password" {
  description = "Cloud-init password"
  type        = string
  default     = ""
  sensitive   = true
}

variable "ssh_public_keys" {
  description = "SSH public keys to add to the VM"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags to apply to the VM (semicolon-separated)"
  type        = string
  default     = ""
}

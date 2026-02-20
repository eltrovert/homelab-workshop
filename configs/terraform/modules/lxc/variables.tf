variable "target_node" {
  description = "Proxmox node to deploy the LXC container on"
  type        = string
}

variable "hostname" {
  description = "Hostname for the LXC container"
  type        = string
}

variable "description" {
  description = "Description for the LXC container"
  type        = string
  default     = ""
}

variable "vmid" {
  description = "VM ID for the LXC container"
  type        = number
  default     = null
}

variable "ostemplate" {
  description = "OS template to use for the LXC container (only needed for new containers)"
  type        = string
  default     = ""
}

variable "unprivileged" {
  description = "Whether to run the container as unprivileged"
  type        = bool
  default     = true
}

variable "onboot" {
  description = "Whether to start the container on boot"
  type        = bool
  default     = true
}

variable "start" {
  description = "Whether to start the container after creation"
  type        = bool
  default     = true
}

variable "cores" {
  description = "Number of CPU cores"
  type        = number
  default     = 2
}

variable "memory" {
  description = "Amount of RAM in MB"
  type        = number
  default     = 2048
}

variable "swap" {
  description = "Amount of swap in MB"
  type        = number
  default     = 512
}

variable "rootfs_storage" {
  description = "Storage location for rootfs"
  type        = string
  default     = "local-lvm"
}

variable "rootfs_size" {
  description = "Size of the rootfs"
  type        = string
  default     = "8G"
}

variable "network_name" {
  description = "Network interface name"
  type        = string
  default     = "eth0"
}

variable "network_bridge" {
  description = "Network bridge to use"
  type        = string
  default     = "vmbr0"
}

variable "network_ip" {
  description = "IP address in CIDR notation"
  type        = string
}

variable "network_gateway" {
  description = "Gateway IP address"
  type        = string
  default     = "192.168.10.1"
}

variable "features_nesting" {
  description = "Enable nesting (required for Docker)"
  type        = bool
  default     = false
}

variable "features_keyctl" {
  description = "Enable keyctl (required for Docker)"
  type        = bool
  default     = false
}

variable "features_fuse" {
  description = "Enable FUSE"
  type        = bool
  default     = false
}

variable "ssh_public_keys" {
  description = "SSH public keys to add to the container"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags to apply to the container (semicolon-separated)"
  type        = string
  default     = ""
}

# Proxmox connection variables
variable "proxmox_api_url" {
  description = "Proxmox API URL"
  type        = string
  default     = ""
}

variable "proxmox_tls_insecure" {
  description = "Skip TLS verification"
  type        = bool
  default     = true
}

# API Token authentication (recommended)
variable "proxmox_api_token_id" {
  description = "Proxmox API Token ID (format: user@realm!tokenname)"
  type        = string
  default     = ""
}

variable "proxmox_api_token_secret" {
  description = "Proxmox API Token Secret"
  type        = string
  sensitive   = true
  default     = ""
}

# Alternative: Username/Password authentication
variable "proxmox_user" {
  description = "Proxmox API user (alternative to API token)"
  type        = string
  default     = ""
}

variable "proxmox_password" {
  description = "Proxmox API password (alternative to API token)"
  type        = string
  sensitive   = true
  default     = ""
}

# Common variables
variable "ssh_public_key" {
  description = "SSH public key to add to containers/VMs"
  type        = string
  default     = ""
}

variable "default_gateway" {
  description = "Default gateway IP"
  type        = string
  default     = "192.168.10.1"
}

variable "default_nameserver" {
  description = "Default DNS nameserver"
  type        = string
  default     = "192.168.10.1"
}

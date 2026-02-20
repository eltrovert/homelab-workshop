terraform {
  required_version = ">= 1.0"

  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.71"
    }
  }
}

provider "proxmox" {
  endpoint = var.proxmox_api_url
  insecure = var.proxmox_tls_insecure

  # API Token authentication (format: user@realm!tokenname=secret)
  api_token = var.proxmox_api_token_secret != "" ? "${var.proxmox_api_token_id}=${var.proxmox_api_token_secret}" : null

  # Alternative: Username/Password authentication
  # username = var.proxmox_user
  # password = var.proxmox_password
}

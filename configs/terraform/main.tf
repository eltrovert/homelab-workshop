# Docker Host LXC Container
module "docker_host" {
  source = "./modules/lxc"

  target_node = "prx01"
  hostname    = "docker-host"
  description = "Docker host running compose services (AdGuard, Vaultwarden, Homarr, Cloudflared, NPM)"
  vmid        = 100

  # OS template (download first: pveam download local ubuntu-24.04-standard)
  ostemplate = "local:vztmpl/ubuntu-24.04-standard_24.04-2_amd64.tar.zst"

  # Run as privileged container for Docker
  unprivileged = false

  # Resources
  cores  = 4
  memory = 8192
  swap   = 2048

  # Storage
  rootfs_storage = "local-lvm"
  rootfs_size    = "64G"

  # Network
  network_ip      = "192.168.10.50/24"
  network_gateway = var.default_gateway

  # SSH
  ssh_public_keys = var.ssh_public_key

  # Features required for Docker
  features_nesting = true
  features_keyctl  = true
  features_fuse    = true

  # Tags
  tags = "docker;services"
}

# Example: Additional LXC container (uncomment to use)
# module "tailscale_gateway" {
#   source = "./modules/lxc"
#
#   target_node = "prx01"
#   hostname    = "tailscale-gw"
#   description = "Tailscale subnet router for remote access"
#   vmid        = 101
#
#   ostemplate   = "local:vztmpl/ubuntu-24.04-standard_24.04-2_amd64.tar.zst"
#   unprivileged = true
#
#   cores  = 1
#   memory = 512
#
#   rootfs_storage = "local-lvm"
#   rootfs_size    = "8G"
#
#   network_ip      = "192.168.10.51/24"
#   network_gateway = var.default_gateway
#   ssh_public_keys = var.ssh_public_key
#
#   features_nesting = true
#
#   tags = "networking;vpn"
# }

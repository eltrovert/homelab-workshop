output "container_id" {
  description = "The ID of the created LXC container"
  value       = proxmox_virtual_environment_container.container.vm_id
}

provider "proxmox" {
  endpoint = var.proxmox_endpoint
  insecure = var.proxmox_insecure_tls

  # Recommended: API token auth
  api_token = var.proxmox_api_token
}

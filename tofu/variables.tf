variable "proxmox_endpoint" {
  type        = string
  description = "Proxmox API endpoint, e.g. https://pve.local:8006/api2/json"
}

variable "proxmox_api_token" {
  type        = string
  description = "Proxmox API token (recommended), e.g. user@pam!token=xxxx"
  sensitive   = true
}

variable "proxmox_insecure_tls" {
  type        = bool
  description = "Set true if using self-signed certs and you accept insecure TLS"
  default     = true
}

# We'll add jax-data LXC variables later (cpu, mem, disk, ip, template, etc.)

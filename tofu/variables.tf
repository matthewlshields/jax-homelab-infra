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
variable "lxc_temp_password" {
  type        = string
  description = "Temporary password for initial LXC creation"
  sensitive   = true
}

# ========== jax-data LXC variables ==========
variable "jax_data_cpu_cores" {
  type        = number
  description = "CPU cores for jax-data container"
  default     = 2
}

variable "jax_data_memory" {
  type        = number
  description = "Memory in MB for jax-data container"
  default     = 2048
}

variable "jax_data_disk_size" {
  type        = number
  description = "Disk size in GB for jax-data container"
  default     = 20
}

variable "jax_data_ip" {
  type        = string
  description = "Static IP for jax-data (CIDR notation, e.g., 192.168.1.102/24). Leave empty for DHCP."
  default     = ""
}

variable "default_gateway" {
  type        = string
  description = "Default gateway for static IP assignments"
  default     = "192.168.1.1"
}

variable "dns_servers" {
  type        = list(string)
  description = "DNS servers for LXC containers"
  default     = ["192.168.1.1"]
}

variable "ssh_public_keys" {
  type        = list(string)
  description = "SSH public keys for LXC access"
  default     = []
}

resource "proxmox_virtual_environment_container" "jax_data" {
  node_name = "pve1"
  vm_id     = 102
  pool_id   = "jax"

  description = "Jax knowledge base - Postgres 18 + pgvector"

  unprivileged = true
  started      = true

  initialization {
    hostname = "jax-data"

    user_account {
      password = var.lxc_temp_password
      keys     = var.ssh_public_keys
    }

    ip_config {
      ipv4 {
        address = var.jax_data_ip != "" ? var.jax_data_ip : "dhcp"
        gateway = var.jax_data_ip != "" ? var.default_gateway : null
      }
    }

    dns {
      domain  = "castle.shields.cc"
      servers = var.dns_servers
    }
  }

  operating_system {
    template_file_id = "synonas1:vztmpl/debian-12-standard_12.12-1_amd64.tar.zst"
    type             = "debian"
  }

  disk {
    datastore_id = "local-lvm"
    size         = var.jax_data_disk_size
  }

  cpu {
    cores = var.jax_data_cpu_cores
  }

  memory {
    dedicated = var.jax_data_memory
  }

  features {
    nesting = true
  }

  tags = ["jax", "postgres", "pgvector"]
}

output "jax_data_ip" {
  description = "IP address of jax-data container"
  value       = proxmox_virtual_environment_container.jax_data.initialization[0].ip_config[0].ipv4[0].address
}

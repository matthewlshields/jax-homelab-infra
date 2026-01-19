resource "proxmox_virtual_environment_container" "hello" {
  node_name = "pve1"
  vm_id     = 101
  pool_id   = "jax"  # Restrict to jax pool for RBAC isolation

  unprivileged = true
  started      = false

  initialization {
    hostname = "jax-hello"

    # Temporary password for learning. We'll switch to SSH keys soon.
    user_account {
      password = var.lxc_temp_password
    }

    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }
  }

#   network_interface {
#     name   = "eth0"
#     bridge = "vmbr0"
#   }

  operating_system {
    # Your CT template lives on synonas1
    template_file_id = "synonas1:vztmpl/debian-12-standard_12.12-1_amd64.tar.zst"
    type             = "debian"
  }

  disk {
    datastore_id = "local-lvm"
    size         = 4
  }

  cpu {
    cores = 1
  }

  memory {
    dedicated = 512
  }
}

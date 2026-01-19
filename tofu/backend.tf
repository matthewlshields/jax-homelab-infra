terraform {
  backend "s3" {
    bucket       = "jax-homelab-tofu-state-061805"
    key          = "jax/proxmox/terraform.tfstate"
    region       = "us-east-1"
    use_lockfile = true
    encrypt      = true
  }
}

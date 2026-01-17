# jax-homelab-infra

Homelab infrastructure for Jax (Proxmox + LXCs + CI/CD).

[![OpenSSF Scorecard](https://api.scorecard.dev/projects/github.com/matthewlshields/jax-homelab-infra/badge)](https://scorecard.dev/viewer/?uri=github.com/matthewlshields/jax-homelab-infra)

## High-level
- OpenTofu for IaC
- Remote state: S3 + lockfile
- GitHub Actions: self-hosted runner
- Podman: jobs run inside a toolbox container
- Secrets: 1Password CLI (op)

## Repo structure
- `tofu/`     OpenTofu IaC for Proxmox resources (jax-data first)
- `ansible/`  Configuration management (Postgres 18 + pgvector)
- `images/`   CI toolbox image (tofu + ansible + awscli + op)

## License

Copyright © 2026 Matthew L. Shields

All rights reserved.

This repository is currently private and not licensed for use, modification,
or redistribution. A license may be added in the future.

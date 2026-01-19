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
- `tofu/`     OpenTofu IaC for Proxmox resources
- `ansible/`  Configuration management (Postgres 18 + pgvector)
- `images/`   CI toolbox image (tofu + ansible + awscli + op)

## Quick Start

### Prerequisites
1. Proxmox VE 8.x with API token configured
2. AWS credentials for S3 state backend
3. 1Password CLI (`op`) for secrets

### Deploy jax-data (Postgres + pgvector)

```bash
# 1. Set up Proxmox RBAC (run on pve1 as root)
./jax-tofu-rbac.sh

# 2. Create the LXC container
cd tofu
source ../set_aws_credentials.sh
tofu init
tofu plan
tofu apply

# 3. Configure Postgres + pgvector
cd ../ansible
export JAX_DB_PASSWORD=$(op read "op://Homelab/jax-data-postgres/password")
ansible-playbook -i inventories/homelab playbooks/jax-data.yml
```

## Components

### jax-data
Postgres 18 + pgvector for Jax's knowledge base.

**Database schema:**
- `embeddings` - RAG/knowledge base storage with vector similarity search
- `conversations` - Chat memory with semantic search
- `tasks` - GTD-style task management

**Connection:**
```
postgresql://jax:****@jax-data.castle.shields.cc:5432/jax
```

## Roadmap
- [x] Tofu RBAC with pool isolation
- [x] jax-data LXC provisioning
- [x] Postgres 18 + pgvector setup
- [ ] jax-brain (Spring Boot + Spring AI)
- [ ] MCP gateway for tool integration
- [ ] Multi-agent orchestration

## License

Copyright © 2026 Matthew L. Shields

All rights reserved.

This repository is currently private and not licensed for use, modification,
or redistribution. A license may be added in the future.

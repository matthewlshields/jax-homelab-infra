#!/usr/bin/env bash
set -euo pipefail

# ====== SETTINGS (edit if needed) ======
USER="jax-tofu@pve"
ROLE="JaxTofuLXC"
TOKENID="tofu-lxc"
NODE="pve1"

# Storage IDs in Proxmox
STORAGE_VM="local-lvm"     # where rootfs will live
STORAGE_TMPL="synonas1"    # where LXC templates live

# Optional pool (recommended)
POOL="jax"
USE_POOL=1

# Optional SDN path (only needed if your Proxmox triggers SDN checks for bridges)
# If you don't use SDN at all, leave USE_SDN=0.
USE_SDN=0
SDN_PATH="/sdn/zones/localnetwork/vmbr0"

# ====== Helper ======
exists_user() { pvesh get "/access/users/${USER}" >/dev/null 2>&1; }
exists_role() { pveum role list | awk '{print $1}' | grep -qx "${ROLE}"; }
exists_token() { pveum user token list "${USER}" 2>/dev/null | awk 'NR>1{print $1}' | grep -qx "${TOKENID}"; }
exists_pool() { pvesh get "/pools/${POOL}" >/dev/null 2>&1; }

echo "[0/7] Preflight checks"
pvesh get "/nodes/${NODE}" >/dev/null
pvesh get "/storage/${STORAGE_VM}" >/dev/null
pvesh get "/storage/${STORAGE_TMPL}" >/dev/null
if [[ "${USE_POOL}" == "1" ]]; then
  if ! exists_pool; then
    echo "      Pool ${POOL} not found; it will be created."
  fi
fi
if [[ "${USE_SDN}" == "1" ]]; then
  pvesh get "${SDN_PATH}" >/dev/null
fi

echo "[1/7] Creating user (if missing): ${USER}"
if ! exists_user; then
  # --comment is optional, but helps auditability
  pveum user add "${USER}" --comment "OpenTofu automation user (token-only)"
else
  echo "      User already exists."
fi

echo "[2/7] Creating pool (optional): ${POOL}"
if [[ "${USE_POOL}" == "1" ]]; then
  if ! exists_pool; then
    pveum pool add "${POOL}" --comment "Jax homelab resources"
  else
    echo "      Pool already exists."
  fi
fi

echo "[3/7] Creating or updating role: ${ROLE}"

# Least-privilege role for LXC create/modify + read-only node visibility + storage
# Notes:
# - Datastore.AllocateTemplate is often required when using templates on NFS-backed storage
# - SDN.* is optional; only enable if needed in your environment
# - VM.Monitor is needed to query/list containers and see their status
PRIVS="Sys.Audit,Datastore.Audit,Datastore.AllocateSpace,Datastore.AllocateTemplate,VM.Audit,VM.Monitor,VM.Allocate,VM.PowerMgmt,VM.Config.CPU,VM.Config.Memory,VM.Config.Disk,VM.Config.Network,VM.Config.Options"
if [[ "${USE_SDN}" == "1" ]]; then
  PRIVS="${PRIVS},SDN.Audit,SDN.Use"
fi

if exists_role; then
  pveum role modify "${ROLE}" -privs "${PRIVS}"
else
  pveum role add "${ROLE}" -privs "${PRIVS}"
fi

# NOTE: We use privsep=0 because privsep=1 tokens have issues listing VMs/containers
# even with correct ACLs. With privsep=0, the token inherits user permissions + ACLs.
echo "[4/7] Creating token (privsep=0): ${USER}!${TOKENID}"
if exists_token; then
  echo "      Token exists already; deleting and recreating for clean secret rotation."
  pveum user token remove "${USER}" "${TOKENID}"
fi

# This prints the secret ONCE. Copy it into 1Password and your local secrets file.
echo
echo "==== TOKEN SECRET (COPY NOW; WILL NOT BE SHOWN AGAIN) ===="
pveum user token add "${USER}" "${TOKENID}" --privsep 0
echo "========================================================="
echo

echo "[5/7] Assigning ACLs to USER (required for privsep=0 inheritance)"

# Remove any existing ACLs for user and token to start clean
for PRINCIPAL_TYPE in "-user" "-token"; do
  PRINCIPAL="${USER}"
  [[ "${PRINCIPAL_TYPE}" == "-token" ]] && PRINCIPAL="${USER}!${TOKENID}"
  pveum aclmod "/nodes/${NODE}"           -delete ${PRINCIPAL_TYPE} "${PRINCIPAL}" 2>/dev/null || true
  pveum aclmod "/vms"                     -delete ${PRINCIPAL_TYPE} "${PRINCIPAL}" 2>/dev/null || true
  pveum aclmod "/storage/${STORAGE_VM}"   -delete ${PRINCIPAL_TYPE} "${PRINCIPAL}" 2>/dev/null || true
  pveum aclmod "/storage/${STORAGE_TMPL}" -delete ${PRINCIPAL_TYPE} "${PRINCIPAL}" 2>/dev/null || true
  if [[ "${USE_POOL}" == "1" ]]; then
    pveum aclmod "/pool/${POOL}"          -delete ${PRINCIPAL_TYPE} "${PRINCIPAL}" 2>/dev/null || true
  fi
  if [[ "${USE_SDN}" == "1" ]]; then
    pveum aclmod "${SDN_PATH}"            -delete ${PRINCIPAL_TYPE} "${PRINCIPAL}" 2>/dev/null || true
  fi
done

# Apply ACLs to USER (token inherits via privsep=0)
# Pool-based restriction: Only grant access to /pool/jax - this limits visibility
# to containers/VMs that are members of the jax pool.
pveum aclmod "/nodes/${NODE}"         -user "${USER}" -role "${ROLE}"
pveum aclmod "/storage/${STORAGE_VM}" -user "${USER}" -role "${ROLE}"
pveum aclmod "/storage/${STORAGE_TMPL}" -user "${USER}" -role "${ROLE}"
if [[ "${USE_POOL}" == "1" ]]; then
  # Pool ACL grants access to VMs/CTs within the pool
  pveum aclmod "/pool/${POOL}"        -user "${USER}" -role "${ROLE}"
  echo "      NOTE: Token can only see/manage VMs in pool '${POOL}'."
  echo "      Add VMs to pool with: pvesh set /pools/${POOL} -vms <vmid>"
else
  # Without pool restriction, grant broad /vms access
  pveum aclmod "/vms"                 -user "${USER}" -role "${ROLE}"
fi
if [[ "${USE_SDN}" == "1" ]]; then
  pveum aclmod "${SDN_PATH}"          -user "${USER}" -role "${ROLE}"
fi

echo "[6/7] Showing ACLs for user"
pveum acl list | grep -F "${USER}" || echo "      (no ACLs found)"

echo "[7/7] Done."
echo
echo "NEXT STEPS:"
echo "  1. Copy the token secret to 1Password"
echo "  2. Set proxmox_api_token to: ${USER}!${TOKENID}=<SECRET>"
if [[ "${USE_POOL}" == "1" ]]; then
  echo "  3. Add VMs to pool '${POOL}' for Tofu to manage them:"
  echo "     pvesh set /pools/${POOL} -vms <vmid>"
  echo "     Or add pool='${POOL}' to your Tofu LXC resources"
fi
echo

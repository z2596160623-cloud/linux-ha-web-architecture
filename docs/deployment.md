# Deployment Guide

## Prerequisites

- Rocky Linux 8-compatible virtual machines on an isolated network.
- An Ansible control node with SSH key access to every managed host.
- DNS or `/etc/hosts` entries matching the inventory names.
- The `community.mysql` Ansible collection.

## Secret preparation

Never place passwords in the inventory. Create and encrypt a Vault file:

```bash
cd ansible
cp vault.example.yml vault.yml
vi vault.yml
ansible-vault encrypt vault.yml
```

The encrypted file may be kept locally. It is ignored by Git and should not be committed.

## Inventory

```bash
cp inventory.example.ini inventory.ini
vi inventory.ini
ansible -i inventory.ini all -m ping
```

If `web3` is intentionally offline, use `--limit '!web3'` for ad-hoc checks or remove it from the working inventory.

## Provisioning

```bash
ansible-galaxy collection install -r collections/requirements.yml
ansible-playbook -i inventory.ini site.yml -e @vault.yml --ask-vault-pass
```

The play order is deliberate: baseline packages, NFS, MySQL, web mounts, then HAProxy and Keepalived.

## Content deployment

This public repository does not include the WordPress archive or database dump. Copy your own application into the NFS export path and import your own database before exposing the VIP.

## Validation

```bash
VIP_URL=http://192.168.88.80 \
WEB_URLS="http://192.168.88.11 http://192.168.88.12" \
../scripts/smoke-test.sh
```

Expected results:

- each backend and the VIP returns HTTP 200;
- the backend content hashes match;
- the VIP content hash matches the backend hash;
- HAProxy reports online backends as UP.

## Lab-only assumptions

Private RFC 1918 addresses, root-level automation, and a single NFS/MySQL node are acceptable for this isolated lab only. A production rollout requires least-privilege accounts, TLS, hardened firewalls, secret rotation, monitoring, backups, and redundant stateful services.

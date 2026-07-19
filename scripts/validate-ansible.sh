#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ansible_dir="${repo_root}/ansible"

cd "${ansible_dir}"

if [[ ! -f inventory.ini ]]; then
  cp inventory.example.ini inventory.ini
fi

if [[ ! -f vault.yml ]]; then
  cp vault.example.yml vault.yml
fi

ansible-galaxy collection install -r collections/requirements.yml
ansible-inventory -i inventory.ini --graph
ansible-playbook -i inventory.ini site.yml -e @vault.yml --syntax-check

echo "PASS: inventory and playbook syntax are valid."

# Security Policy

This repository contains lab automation and redacted runtime evidence. It intentionally excludes SSH passwords, database passwords, private keys, WordPress archives, VM disks, and Ansible Vault files.

Before running the automation:

- use SSH keys instead of password authentication;
- copy `ansible/vault.example.yml` to `ansible/vault.yml` and encrypt it;
- replace the lab-only network addresses with your own isolated network;
- restrict HAProxy statistics and MySQL access with firewall rules;
- do not expose this Rocky Linux 8.6 lab directly to the Internet.

If you find an accidental secret, open a private security report instead of a public issue.

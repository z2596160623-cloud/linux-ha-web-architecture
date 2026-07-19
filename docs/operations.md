# Operations Runbook

## Daily checks

```bash
systemctl is-active haproxy keepalived
systemctl is-active nginx php-fpm
systemctl is-active mysqld
systemctl is-active rpcbind nfs-server
```

Check VIP ownership:

```bash
ip -4 address show dev eth0 | grep 192.168.88.80
```

Check shared storage from every web node:

```bash
findmnt /usr/share/nginx/html
touch /usr/share/nginx/html/.write-test && rm /usr/share/nginx/html/.write-test
```

Check HAProxy configuration before reload:

```bash
haproxy -c -f /etc/haproxy/haproxy.cfg
systemctl reload haproxy
```

## Safe rollout order

1. Back up MySQL and application files.
2. Validate NFS and MySQL before changing the web tier.
3. Remove one web backend from traffic or wait for health checks.
4. Update and verify one web node at a time.
5. Restore the backend, then continue to the next node.
6. Validate the VIP and compare response hashes.

## Load-balancer failover drill

Run the drill only in a maintenance window:

1. Record the current VIP owner.
2. Continuously request the VIP from a client.
3. Stop Keepalived on the current MASTER.
4. Confirm the VIP appears on the BACKUP and requests recover.
5. Restart Keepalived and confirm the intended ownership policy.
6. Record interruption time and all observed errors.

The repository does not automate service shutdown because failure injection is an intentional, potentially disruptive action.

## Backup scope

- MySQL logical backups and restore tests.
- NFS application files and uploaded media.
- Ansible inventory, encrypted Vault, and configuration repository.
- HAProxy and Keepalived configuration snapshots before changes.

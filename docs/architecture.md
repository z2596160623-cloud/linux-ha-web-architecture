# Architecture

## Design goals

The lab demonstrates horizontal web scaling, separation of state, automated configuration, load-balancer redundancy, and observable health checks on a small local virtualization host.

## Node map

| Role | Host | Address | Responsibility |
| --- | --- | --- | --- |
| Control | pubserver | 192.168.88.240 | Ansible control and artifact distribution |
| Load balancer | haproxy01 | 192.168.88.5 | HAProxy and Keepalived MASTER |
| Load balancer | haproxy02 | 192.168.88.6 | HAProxy and Keepalived BACKUP |
| Virtual IP | — | 192.168.88.80 | Stable client entry point |
| Web | web1 | 192.168.88.11 | Nginx, PHP-FPM, WordPress |
| Web | web2 | 192.168.88.12 | Nginx, PHP-FPM, WordPress |
| Web | web3 | 192.168.88.13 | Optional horizontal-capacity node |
| Database | database | 192.168.88.21 | MySQL and WordPress data |
| Storage | nfs | 192.168.88.31 | Shared WordPress files |

## Request path

1. A client requests the Keepalived VIP.
2. The active HAProxy node accepts the connection.
3. HAProxy selects a healthy Nginx backend using round-robin scheduling.
4. PHP-FPM executes WordPress requests.
5. WordPress reads structured data from MySQL and files from the NFS mount.

## Failure behavior

- If a web node fails, HAProxy removes it after the configured health-check threshold.
- If the active load balancer fails, Keepalived moves the VIP to the backup.
- Web nodes are replaceable because application state is externalized.
- MySQL and NFS remain single points of failure in this lab; production evolution options are documented in the main README.

## Resource strategy

The complete lab fits on a 16 GB workstation by assigning 512 MB to most infrastructure nodes and starting machines sequentially. Validation can run with two web nodes while the third remains powered off.

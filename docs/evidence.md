# Runtime Evidence

## Collection scope

Evidence was collected from the local lab on 2026-07-19 using read-only SSH commands, HTTP requests, systemd status checks, HAProxy statistics, and page hashes. Credentials, private keys, VM disks, WordPress archives, database dumps, and training-provider identifiers are excluded.

## Verified nodes

| Node | Evidence |
| --- | --- |
| pubserver | Rocky Linux 8.6, Ansible Core 2.13.3, 14 staged playbooks present |
| haproxy01 | HAProxy and Keepalived active, VIP present |
| haproxy02 | HAProxy and Keepalived active, no VIP while BACKUP |
| web1 | Nginx and PHP-FPM active, HTTP 200 after NFS recovery |
| web2 | Nginx and PHP-FPM active, HTTP 200 after NFS recovery |
| database | MySQL active, WordPress database present, port 3306 listening |
| nfs | RPC/NFS active, `/nfs_root` exported to the lab subnet |

`web3` was intentionally powered off to save host memory. HAProxy correctly marked it DOWN, which validates backend health-check behavior without claiming that all three web nodes were online during this evidence capture.

## HTTP consistency

| URL | Status | Bytes | SHA-256 prefix |
| --- | --- | ---: | --- |
| `http://192.168.88.11/` | 200 | 53,227 | `cfbf5e351945e5d6` |
| `http://192.168.88.12/` | 200 | 53,227 | `cfbf5e351945e5d6` |
| `http://192.168.88.80/` | 200 | 53,227 | `cfbf5e351945e5d6` |

## HAProxy health state

| Backend | Status | Last check |
| --- | --- | --- |
| web1 | UP | L4OK |
| web2 | UP | L4OK |
| web3 | DOWN | L4 timeout, expected because powered off |

The screenshots in `assets/screenshots/` are direct captures of the VIP page and HAProxy statistics page after recovery.

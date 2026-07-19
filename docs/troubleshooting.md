# Troubleshooting Record: HTTP 403 After Lab Startup

## Symptom

The VIP and both running Nginx backends were reachable, but the backends initially returned HTTP 403.

## Evidence

- Nginx and PHP-FPM were active.
- MySQL was active and the WordPress database existed.
- NFS and RPC services were active and `/nfs_root` was exported.
- `findmnt /usr/share/nginx/html` returned no mount on `web1` or `web2`.

## Root cause

The web document root existed as an empty local directory because the NFS mount had not been restored after the virtual machines started. Nginx therefore had no usable index content and returned 403.

## Recovery

The existing mount playbook was reapplied only to the two running web nodes:

```bash
ansible-playbook 12-mount-nfs.yml --limit web1,web2
```

Ansible reported `changed=1`, `failed=0` for both hosts.

## Verification

- `web1`, `web2`, and the VIP all returned HTTP 200.
- All three responses had the same byte length and SHA-256 prefix.
- HAProxy reported `web1` and `web2` as `UP / L4OK`.
- The intentionally powered-off `web3` was reported as `DOWN / L4 timeout`.

## Preventive improvements

- Provision NFS before the web role in `site.yml`.
- Use Ansible's `mount` module with `state: mounted` so `/etc/fstab` is persistent.
- Add the smoke test to every startup and change window.
- Alert on HTTP status, mount disappearance, and backend health-state changes.

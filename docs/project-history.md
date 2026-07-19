# Project Evolution

The original implementation was built incrementally through 14 playbooks:

1. repository configuration;
2. initial single-node LNMP setup;
3. local WordPress database initialization;
4. standalone database provisioning;
5. web-tier package deployment;
6. application archive collection from the first web node;
7. application deployment to additional web nodes;
8. NFS service provisioning;
9. updated application archive collection;
10. content deployment to NFS;
11. local document-root replacement;
12. persistent NFS mounts on web nodes;
13. HAProxy and Keepalived package deployment;
14. HAProxy backend and statistics configuration.

The public version keeps that implementation history in the documentation, while `ansible/roles/` presents the refactored, idempotent, secret-free design. Large site archives and plaintext credentials are deliberately excluded.

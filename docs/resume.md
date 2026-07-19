# Resume-ready Project Description

## 中文版

**Linux Web 高可用架构实验室｜个人项目**

- 独立设计并搭建 8 节点 Rocky Linux Web 架构，覆盖 Ansible 控制、双 HAProxy/Keepalived、3 节点 Nginx/PHP-FPM、独立 MySQL 与 NFS 共享存储。
- 编写并重构 14 个阶段式 Ansible Playbook，通过 Roles 实现服务安装、配置分发、开机自启、NFS 持久挂载和负载均衡自动化。
- 配置 Keepalived VRRP 主备和 VIP 漂移，使用 HAProxy round-robin、健康检查与监控页实现后端故障摘除。
- 将 WordPress 数据库与文件状态从 Web 层分离；排查 NFS 未挂载导致的 HTTP 403，并恢复双后端及 VIP HTTP 200，验证页面哈希一致。

关键词：Linux、Rocky Linux、Ansible、Nginx、HAProxy、Keepalived、MySQL、NFS、WordPress、高可用、故障排查

## English

**Linux High-Availability Web Architecture Lab | Personal Project**

- Designed and built an eight-node Rocky Linux web lab with Ansible control, redundant HAProxy/Keepalived nodes, three Nginx/PHP-FPM nodes, standalone MySQL, and NFS shared storage.
- Authored and refactored 14 staged Ansible playbooks into reusable roles for package installation, configuration delivery, service enablement, persistent NFS mounts, and load balancing.
- Implemented a VRRP floating VIP, round-robin scheduling, active backend checks, and failure-based backend removal.
- Separated WordPress state from the web tier; diagnosed an NFS mount failure that caused HTTP 403 and restored HTTP 200 with identical content hashes across both active backends and the VIP.

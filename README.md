# Linux Web 高可用架构实验室

[English](README_EN.md) · [部署指南](docs/deployment.md) · [运维手册](docs/operations.md) · [故障复盘](docs/troubleshooting.md)

这是一个由我独立搭建、配置和验证的 Rocky Linux 多节点 Web 高可用实验室。项目以 WordPress 为业务载荷，通过 Ansible 自动化完成 Web、数据库、共享存储、负载均衡和 VIP 高可用配置，并保留了真实运行截图与故障恢复记录。

> 定位：个人云计算 / Linux 运维作品集项目。它复现了企业 Web 架构中的关键组件，但不宣称是未经改造即可投入生产的方案。

![Architecture](assets/architecture.svg)

## 项目亮点

- **8 节点完整拓扑**：1 个 Ansible 控制节点、2 个 HAProxy/Keepalived、3 个 Nginx/PHP-FPM、1 个 MySQL、1 个 NFS。
- **双层高可用**：Keepalived 提供 `192.168.88.80` VIP 漂移，HAProxy 使用 round-robin 和主动健康检查分发请求。
- **状态与计算分离**：MySQL 独立部署；WordPress 文件由 NFS 集中存储，多台 Web 共享同一份站点数据。
- **自动化交付**：将最初的 14 个分阶段 Playbook 重构为可复用的 Ansible Roles，并用 Vault 变量隔离密码。
- **真实故障闭环**：启动验证时发现 NFS 未挂载导致 Nginx 返回 403；使用 Ansible 恢复挂载后，两个后端和 VIP 均返回 HTTP 200。
- **可观察、可验证**：HAProxy 监控页能够区分在线后端与主动关机节点，验证健康检查确实生效。

## 真实验证结果

验证日期：**2026-07-19**。为控制 16 GB 宿主机内存，本次验证主动关闭 `web3`，使用 `web1` 和 `web2` 承载流量。

| 检查项 | 结果 |
| --- | --- |
| Keepalived VIP | `192.168.88.80` 位于 `haproxy01` |
| HAProxy / Keepalived | 两个节点服务均为 `active` |
| Web 后端 | `web1`、`web2` 为 `UP / L4OK` |
| 关机节点检测 | `web3` 为 `DOWN / L4 timeout` |
| HTTP 一致性 | 两个后端与 VIP 均返回 `200`，页面哈希一致 |
| 数据库 | MySQL `active`，WordPress 数据库存在，3306 监听 |
| 共享存储 | NFS/RPC `active`，导出 `/nfs_root` |

![VIP WordPress](assets/screenshots/vip-home.png)

![HAProxy health checks](assets/screenshots/haproxy-stats.png)

完整证据与验证边界见 [docs/evidence.md](docs/evidence.md)。

## 技术栈

| 层级 | 组件 |
| --- | --- |
| 操作系统 | Rocky Linux 8.6 |
| 自动化 | Ansible Core 2.13.3 |
| 接入与高可用 | HAProxy、Keepalived、VRRP、VIP |
| Web | Nginx、PHP-FPM、WordPress |
| 数据 | MySQL、NFS |
| 验证 | curl、HAProxy stats、systemd、SHA-256 |

## 仓库结构

```text
.
├── ansible/                 # 角色化、无明文密码的自动化配置
│   ├── roles/               # common/web/database/nfs/haproxy/keepalived
│   ├── group_vars/          # 非敏感公共变量
│   ├── host_vars/           # Keepalived 主备差异
│   ├── inventory.example.ini
│   └── site.yml
├── assets/                  # 架构图与脱敏运行截图
├── docs/                    # 架构、部署、运维、证据、故障复盘
├── scripts/                 # 只读健康检查脚本
└── .github/workflows/       # YAML / Ansible / Shell CI
```

## 快速开始

1. 准备 Rocky Linux 8 系列虚拟机，并根据 [inventory.example.ini](ansible/inventory.example.ini) 设置主机地址。
2. 复制 `ansible/vault.example.yml` 为 `ansible/vault.yml`，填写实验环境密码并使用 Ansible Vault 加密。
3. 安装依赖并执行：

```bash
cd ansible
ansible-galaxy collection install -r collections/requirements.yml
ansible-vault encrypt vault.yml
ansible-playbook -i inventory.ini site.yml -e @vault.yml --ask-vault-pass
```

4. 使用只读脚本验证：

```bash
VIP_URL=http://192.168.88.80 \
WEB_URLS="http://192.168.88.11 http://192.168.88.12" \
./scripts/smoke-test.sh
```

详细步骤与安全注意事项见 [docs/deployment.md](docs/deployment.md)。

## 我完成的工作

- 规划并实现多节点地址与服务拓扑；
- 用 Ansible 批量安装、启用和配置 Nginx、PHP-FPM、MySQL、NFS、HAProxy；
- 完成 WordPress 数据库独立、站点目录共享和 Web 横向扩展；
- 配置 HAProxy 后端轮询、健康检查与统计页；
- 配置 Keepalived 主备优先级和 VIP；
- 验证服务状态、端口、页面一致性和故障节点摘除；
- 排查并恢复 NFS 未挂载导致的 HTTP 403；
- 将实验代码重构为可公开复用、无明文凭据的项目仓库。

## 下一步演进

- 为 VIP 增加 HTTPS 与证书自动续期；
- 引入 Prometheus、Node Exporter 与 Grafana；
- 用 MySQL 主从或 InnoDB Cluster 消除数据库单点；
- 用分布式存储或对象存储替换单节点 NFS；
- 增加自动化故障注入和性能基线测试。

## 许可

代码与原创文档使用 [MIT License](LICENSE)。截图仅用于展示该实验室的实际运行结果。

# WuDiXianXin 的 dotfiles

个人 dotfiles 仓库，按分支管理不同环境、不同层级的配置文件。

> 注意：这是我的个人配置，可能包含特定硬件、发行版或桌面环境相关设置。使用前请先阅读脚本和配置，并自行备份。

## 当前环境

- 主力系统：CachyOS
- 用户级配置：`main` 分支，使用 [chezmoi](https://www.chezmoi.io/) 管理 `$HOME`
- 系统级配置：`CachyOS` 分支，使用 Bash 脚本管理 `/etc`
- 旧配置存档：`ArchLinux` 分支

## 分支说明

| 分支 | 管理对象 | 管理方式 | 状态 | 说明 |
| --- | --- | --- | --- | --- |
| `main` | `$HOME` 用户级配置 | chezmoi | 当前维护 | 日常使用的 shell、编辑器、终端等用户配置 |
| `CachyOS` | `/etc` 系统级配置 | Bash 脚本 | 当前使用 | 当前主力系统 CachyOS 的系统配置 |
| `ArchLinux` | 旧 Arch Linux 配置 | 手动 / 旧脚本 | 仅存档 | 包含 DMS、Bash 等旧配置，现已不再使用 |

## 使用方式

### 用户级配置：`main`

使用 chezmoi 初始化并应用：

```bash
chezmoi init --apply <本仓库地址>
```

### 系统级配置：`CachyOS`

切换到 `CachyOS` 分支，并先检查脚本内容：

```bash
git switch CachyOS

sudo ./restore.bash
```

> `/etc` 下的配置涉及系统关键文件，执行前请务必备份，并确认脚本内容。

### 旧配置：`ArchLinux`

该分支仅作存档参考，不建议直接使用。

## 分支关系

- `main` 管理 `$HOME` 下的用户级配置。
- `CachyOS` 管理 `/etc` 下的系统级配置。
- 在 CachyOS 上，可以同时使用 `main` 和 `CachyOS` 两个分支。
- `ArchLinux` 是旧环境配置，仅用于回溯和参考。

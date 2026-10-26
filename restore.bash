#!/usr/bin/env bash
set -euo pipefail

[[ -d ./etc ]] || { echo "错误：$backup_dir 下没有 ./etc 目录" >&2; exit 1; }

# --chown=root:root：恢复到 /etc 的文件归 root（系统文件应有的属主）
sudo rsync -av --chown=root:root ./etc/ /etc/

sudo rsync -av --chown=greeter:greeter ./var/lib/noctalia-greeter/greeter.toml /var/lib/noctalia-greeter/

echo "恢复完成。"

#!/usr/bin/env bash
set -euo pipefail

backup_dir="${1:-.}"
cd "$backup_dir"

[[ -d ./etc ]] || { echo "错误：$backup_dir 下没有 ./etc 目录" >&2; exit 1; }

# --chown=root:root：恢复到 /etc 的文件归 root（系统文件应有的属主）
sudo rsync -av --chown=root:root ./etc/ /etc/

echo "恢复完成。"

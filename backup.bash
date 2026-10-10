#!/usr/bin/env bash
set -euo pipefail

paths=(
  /etc/fstab
  /etc/environment
  /etc/profile
  /etc/pacman.conf
  /etc/pacman.d/archlinuxcn
  /etc/default/limine
  /etc/modprobe.d/nvidia.conf
)

# -a 归档模式
# -R/--relative 保留源路径结构
# -v 逐文件输出
# --chown：即使 sudo 读源文件，写出的备份仍归当前用户，避免 git 权限问题
# --ignore-missing-args：某个文件不存在时跳过，不中断
sudo rsync -aRv --ignore-missing-args \
  --chown="$(id -u):$(id -g)" \
  "${paths[@]}" ./

echo "备份完成。"

#!/usr/bin/env bash
set -euo pipefail

BACKUP_ROOT="${BACKUP_ROOT:-.}"

# 获取真实用户的家目录（如果通过 sudo 运行，则还原为原始用户）
if [[ -n "${SUDO_USER:-}" ]]; then
  REAL_HOME="$(getent passwd "$SUDO_USER" | cut -d: -f6)"
else
  REAL_HOME="$HOME"
fi

if ! command -v rsync >/dev/null 2>&1; then
  echo "错误：需要 rsync" >&2
  exit 1
fi

# ---------- 备份项定义 ----------
CONFIG_DIRS=(
  "niri"
  "fish"
  "foot"
  "dgop"
  "fastfetch"
  # "obs-studio"
  "DankMaterialShell"
)

HOME_FILES=(
  # ".bashrc"
  # ".inputrc"
)

HOME_SUBDIRS=(
  "bash"
)

ETC_FILES=(
  "default/grub"
  "modprobe.d/nvidia.conf"
  "pacman.d/mirrorlist"
  "pacman.d/archlinuxcn"
  "pacman.conf"
  "environment"
  "profile"
  "fstab"
)

# ---------- 通用同步函数 ----------
do_rsync() {
  local src="$1"
  local dst="$2"
  local use_sudo="${3:-false}"

  if [[ ! -e "$src" ]]; then
    echo "跳过不存在的源: $src"
    return 0
  fi

  echo "同步: $src -> $dst"

  if [[ -d "$src" ]]; then
    src="${src%/}/"
  fi

  if $use_sudo; then
    sudo rsync -a "$src" "$dst"
  else
    rsync -a "$src" "$dst"
  fi
}

# 固定为备份方向
SRC_PREFIX="$REAL_HOME"
DST_PREFIX="$BACKUP_ROOT"

echo "备份用户文件：$SRC_PREFIX → $DST_PREFIX"

# 1. 用户配置目录
for dir in "${CONFIG_DIRS[@]}"; do
  do_rsync "$SRC_PREFIX/.config/$dir" "$DST_PREFIX/.config/$dir" false
done

# 2. 用户家目录子目录
for subdir in "${HOME_SUBDIRS[@]}"; do
  do_rsync "$SRC_PREFIX/$subdir" "$DST_PREFIX/$subdir" false
done

# 3. 用户家目录文件
for file in "${HOME_FILES[@]}"; do
  do_rsync "$SRC_PREFIX/$file" "$DST_PREFIX/$file" false
done

# 4. 系统配置文件（全程 sudo）
if [[ ${#ETC_FILES[@]} -gt 0 ]]; then
  echo "系统配置部分将使用 sudo"
  sudo -v

  for rel_path in "${ETC_FILES[@]}"; do
    do_rsync "/etc/$rel_path" "$BACKUP_ROOT/etc/$rel_path" true
  done
fi

echo "备份完成。"

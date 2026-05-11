#!/bin/bash

set -euo pipefail

# ------------------------- 依赖检查 -------------------------
check_dependencies() {
  local missing=()
  for cmd in eza fd rg; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
      missing+=("$cmd")
    fi
  done
  if [[ ${#missing[@]} -gt 0 ]]; then
    echo "❌ 错误：缺少依赖：${missing[*]}" >&2
    exit 1
  fi
}
check_dependencies

# ------------------------- 常量 -------------------------
EXCLUDE_DIRS=(
  # VCS 与依赖
  '.git' '.svn' '.hg'
  # 包管理器 / 构建产物
  'node_modules' '__pycache__' 'target' 'vendor' 'bower_components'
  '.gradle' '.build' 'build' 'dist' 'out' 'output'
  # IDE 与编辑器配置
  '.idea' '.vscode' '.vs' '.settings' '.project' '.classpath'
  # 系统与临时
  '.DS_Store' '.Trash' '.Trashes' 'Thumbs.db'
  # 日志 / 缓存 / 临时
  'logs' 'tmp' 'temp' '.cache' '.cargo' '.npm' '.yarn'
  # 编译 / 打包
  '*.egg-info' '*.egg' '*.whl'
  # Godot 特定（如果需要）
  '.godot'
  # 资源 / 素材（示例，可按需调整）
  'assets' '.github'
)

EXCLUDE_FILES=(
  # 敏感信息
  '.env' '.env.*' '*.pem' '*.key' 'id_rsa*' '*.pfx'
  # 编辑器 / 系统残留
  '.DS_Store' 'Thumbs.db' 'desktop.ini'
  # VCS 忽略
  '.gitignore' '.gitattributes' '.gitkeep'
  # 编译中间文件
  '*.pyc' '*.pyo' '*.class' '*.o' '*.obj' '*.exe' '*.dll' '*.so'
  # 压缩包 / 二进制（常见备份不需要的）
  '*.zip' '*.7z' '*.tar' '*.gz' '*.rar'
  # 临时 / 备份文件
  '*~' '*.swp' '*.swo' '*.bak' '*.orig' '*.tmp' '*.log'
  # 特定 IDE 配置（若已在目录排除，这里可留空，但作为双重保险）
  '*.iml' '*.ipr' '*.iws'
  # 证书 / 密钥文件（可能不想备份）
  '*.crt' '*.csr' '*.jks'
  # 包锁定文件（通常很大且可恢复）
  'package-lock.json' 'yarn.lock' 'pnpm-lock.yaml' 'Cargo.lock'
  # Godot 文件
  '*.uid' '*.import' # uid 使用通配符，排除所有 uid 文件；.import 文件夹已在目录排除，这里防止某个 .import 是普通文件（不太可能）
)

# 构建 eza 的排除模式（竖线分隔）
build_exclude_pattern_eza() {
  local IFS='|'
  echo "${EXCLUDE_DIRS[*]}|${EXCLUDE_FILES[*]}"
}
EZA_EXCLUDE_PATTERN=$(build_exclude_pattern_eza)

# 构建 fd 的排除参数（每个 --exclude 独立，fd 支持多次）
build_exclude_args_fd() {
  local args=()
  for d in "${EXCLUDE_DIRS[@]}" "${EXCLUDE_FILES[@]}"; do
    args+=(--exclude "$d")
  done
  printf '%s\n' "${args[@]}"
}
mapfile -t FD_EXCLUDE_ARGS < <(build_exclude_args_fd)

# ------------------------- 辅助函数 -------------------------
msg_info() { echo "ℹ️  $1"; }
msg_warn() { echo "⚠️  $1"; }
msg_error() { echo "❌  $1" >&2; }
msg_success() { echo "✅  $1"; }

ask_confirm() {
  local prompt="$1" default="${2:-n}"
  if [[ "$default" == "y" ]]; then
    read -r -p "$prompt (Y/n): " answer
    [[ -z "$answer" || "$answer" =~ ^[Yy]$ ]]
  else
    read -r -p "$prompt (y/N): " answer
    [[ "$answer" =~ ^[Yy]$ ]]
  fi
}

sanitize_path() {
  local input="$1" result="${input/#\~/$HOME}"
  [[ "$result" = /* ]] || result="$(pwd)/$result"
  echo "$result"
}

check_directory() {
  local dir="$1"
  [[ -e "$dir" ]] || {
    msg_error "路径不存在: $dir"
    return 1
  }
  [[ -d "$dir" ]] || {
    msg_error "路径不是目录: $dir"
    return 1
  }
  [[ -r "$dir" ]] || {
    msg_error "目录无读取权限: $dir"
    return 1
  }
}

# 快速二进制检测（grep -I 对于二进制返回 1）
is_binary_file() {
  ! grep -qI '' "$1" 2>/dev/null
}

# ------------------------- 备份生成 -------------------------
generate_backup() {
  local base_dir="$1" output_file="$2" timestamp="$3"

  {
    # 头部
    cat <<HEADER_EOF
配置目录完整备份
生成时间: $(date +'%Y-%m-%d %H:%M:%S')
源目录: $base_dir
备份时间戳: $timestamp

================================================================================

HEADER_EOF

    # 目录树
    echo "目录结构："
    echo "----------------------------------------"
    eza -T -a --color=never -I "$EZA_EXCLUDE_PATTERN" "$base_dir" 2>/dev/null || true
    echo "========================================"

  } >>"$output_file"

  # 收集并排序文件列表（null分隔，安全处理任意文件名）
  local sorted_files=()
  while IFS= read -r -d '' file; do
    sorted_files+=("$file")
  done < <(fd --type f --hidden "${FD_EXCLUDE_ARGS[@]}" -0 . "$base_dir" 2>/dev/null | sort -z)

  local total=${#sorted_files[@]}
  local current=0 skipped=0

  for full_path in "${sorted_files[@]}"; do
    ((current++))

    if is_binary_file "$full_path"; then
      ((skipped++))
      continue
    fi

    msg_info "处理文件 [$current/$total]: $full_path"

    local rel_path="${full_path#$base_dir/}"
    {
      echo "文件路径: $rel_path"
      echo "----------------------------------------"
      if [[ -r "$full_path" ]]; then
        cat "$full_path"
      else
        echo "(无法读取文件)"
      fi
      echo ""
      echo "========================================"
      echo ""
      echo ""
    } >>"$output_file"
  done

  if ((skipped > 0)); then
    msg_info "已跳过 $skipped 个二进制文件"
  fi

  return 0
}

# ------------------------- 主流程 -------------------------
trap 'echo ""; msg_info "操作已取消。"; exit 0' INT

echo "=============================================="
echo "      目录备份工具 - Directory Backup"
echo "=============================================="
echo ""

read -r -p "请输入要备份的目录路径（支持 ~，直接回车备份当前目录）: " input_dir

if [[ -z "$input_dir" ]]; then
  if ask_confirm "未输入路径，是否备份当前目录（$(pwd)）？" "y"; then
    base_dir="$(pwd)"
  else
    msg_info "已取消操作。"
    exit 0
  fi
else
  base_dir=$(sanitize_path "$input_dir")
fi

check_directory "$base_dir" || exit 1
msg_info "目标目录: $base_dir"

msg_info "正在统计文件数量..."
# 安全统计（fd -0 转成行）
file_count=$(fd --type f --hidden "${FD_EXCLUDE_ARGS[@]}" -0 . "$base_dir" 2>/dev/null | tr '\0' '\n' | wc -l)
msg_info "目录中约包含 $file_count 个文件（已自动排除 ${EXCLUDE_DIRS[*]} 等）"

if [[ "$file_count" -gt 300 ]]; then
  msg_warn "文件数量较多（$file_count），备份文件可能很大。"
  ask_confirm "是否继续？" || {
    msg_info "已取消操作。"
    exit 0
  }
fi

echo ""
msg_warn "注意：备份文件包含所有文件原始内容，请勿直接分享包含敏感信息的备份！"
echo "      （如 API 密钥、私钥、.env 文件内容等会被明文记录）"
echo ""
ask_confirm "确认理解并继续？" "y" || {
  msg_info "已取消操作。"
  exit 0
}

timestamp=$(date +'%Y%m%d-%H%M%S')
if [[ -d "$HOME/Desktop" ]]; then
  output_file="$HOME/Desktop/dir-backup-$timestamp.txt"
else
  output_file="./dir-backup-$timestamp.txt"
fi

echo ""
msg_info "备份中..."
msg_info "输出文件: $output_file"
echo ""

generate_backup "$base_dir" "$output_file" "$timestamp" || {
  msg_error "备份过程中发生错误"
  rm -f "$output_file"
  exit 1
}

echo ""
msg_success "备份完成！"
msg_info "文件已保存到: $output_file"
echo ""
echo "建议命令:"
echo "  nvim \"$output_file\""
echo "  cat \"$output_file\" | less"
echo "  bat \"$output_file\""

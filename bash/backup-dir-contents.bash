#!/bin/bash

set -euo pipefail

check_dependencies() {
    if ! command -v eza >/dev/null 2>&1; then
        echo "❌ 错误：未找到 eza 命令" >&2
        exit 1
    fi

    if ! command -v fd >/dev/null 2>&1; then
        echo "❌ 错误：未找到 fd 命令" >&2
        exit 1
    fi

    if ! command -v rg >/dev/null 2>&1; then
        echo "❌ 错误：未找到 rg (ripgrep) 命令" >&2
        exit 1
    fi
}

check_dependencies

EXCLUDE_DIRS=('.git' 'assets' '.github' 'node_modules' '__pycache__' 'target' '.godot')

msg_info() { echo "ℹ️  $1"; }
msg_warn() { echo "⚠️  $1"; }
msg_error() { echo "❌  $1" >&2; }
msg_success() { echo "✅  $1"; }

ask_confirm() {
    local prompt="$1"
    local default="${2:-n}"
    if [[ "$default" == "y" ]]; then
        echo -n "$prompt (Y/n): "
        read -r answer
        [[ -z "$answer" || "$answer" =~ ^[Yy]$ ]]
    else
        echo -n "$prompt (y/N): "
        read -r answer
        [[ "$answer" =~ ^[Yy]$ ]]
    fi
}

sanitize_path() {
    local input="$1"
    local result="${input/#\~/$HOME}"
    if [[ ! "$result" = /* ]]; then
        result="$(pwd)/$result"
    fi
    echo "$result"
}

check_directory() {
    local dir="$1"
    if [[ ! -e "$dir" ]]; then
        msg_error "路径不存在: $dir"
        return 1
    fi
    if [[ ! -d "$dir" ]]; then
        msg_error "路径不是目录: $dir"
        return 1
    fi
    if [[ ! -r "$dir" ]]; then
        msg_error "目录无读取权限: $dir"
        return 1
    fi
    return 0
}

is_binary_file() {
    local file="$1"
    # 使用 rg 检测是否包含 null 字节（二进制文件特征）
    if rg -q --binary --null "$file" 2>/dev/null; then
        return 0
    fi
    return 1
}

write_header() {
    local output_file="$1"
    local base_dir="$2"
    local timestamp="$3"

    cat > "$output_file" << HEADER_EOF
配置目录完整备份
生成时间: $(date +'%Y-%m-%d %H:%M:%S')
源目录: $base_dir
备份时间戳: $timestamp

================================================================================

HEADER_EOF
}

write_tree() {
    local output_file="$1"
    local base_dir="$2"

    echo "目录结构：" >> "$output_file"
    echo "----------------------------------------" >> "$output_file"

    eza -T -a --color=never -I '.git|assets|.github|node_modules|__pycache__|target|.godot' "$base_dir" >> "$output_file" 2>/dev/null || true

    echo "" >> "$output_file"
    echo "========================================" >> "$output_file"
    echo "" >> "$output_file"
    echo "" >> "$output_file"
}

write_file_contents() {
    local output_file="$1"
    local base_dir="$2"

    # 使用 fd 获取文件列表，结果存入数组
    local files=()
    while IFS= read -r -d '' file; do
        files+=("$file")
    done < <(fd --type f --hidden \
        --exclude=.git --exclude=assets --exclude=.github --exclude=node_modules --exclude=__pycache__ \
        --exclude=target --exclude=.godot \
        --exclude='.env' --exclude='.DS_Store' --exclude='Thumbs.db' \
        -0 . "$base_dir" 2>/dev/null)

    # Bash 数组排序
    local sorted_files=()
    local tmp
    for file in "${files[@]}"; do
        local inserted=false
        for i in "${!sorted_files[@]}"; do
            if [[ "$file" < "${sorted_files[$i]}" ]]; then
                tmp="${sorted_files[$i]}"
                sorted_files[$i]="$file"
                file="$tmp"
            fi
        done
        sorted_files+=("$file")
    done

    # 计算文件数量
    local total=${#sorted_files[@]}
    local current=0
    local skipped=0

    for full_path in "${sorted_files[@]}"; do
        ((current++))

        # 检查是否为二进制文件
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
        } >> "$output_file"
    done

    # 报告跳过的二进制文件
    if [[ $skipped -gt 0 ]]; then
        msg_info "已跳过 $skipped 个二进制文件"
    fi
}

trap 'echo ""; msg_info "操作已取消。"; exit 0' INT

echo "=============================================="
echo "      目录备份工具 - Directory Backup"
echo "=============================================="
echo ""

echo -n "请输入要备份的目录路径（支持 ~，直接回车备份当前目录）: "
read -r input_dir

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

if ! check_directory "$base_dir"; then
    exit 1
fi

msg_info "目标目录: $base_dir"

msg_info "正在统计文件数量..."
file_count=$(fd --type f --hidden \
    --exclude=.git --exclude=assets --exclude=.github --exclude=node_modules --exclude=__pycache__ \
    --exclude=target --exclude=.godot \
    --exclude='.env' --exclude='.DS_Store' --exclude='Thumbs.db' \
    . "$base_dir" 2>/dev/null | echo $(( $(wc -l < /dev/stdin) + 0 )))

msg_info "目录中约包含 $file_count 个文件（已自动排除 ${EXCLUDE_DIRS[*]} 等）"

if [[ "$file_count" -gt 300 ]]; then
    msg_warn "文件数量较多（$file_count），备份文件可能很大。"
    if ! ask_confirm "是否继续？"; then
        msg_info "已取消操作。"
        exit 0
    fi
fi

echo ""
msg_warn "注意：备份文件包含所有文件原始内容，请勿直接分享包含敏感信息的备份！"
echo "      （如 API 密钥、私钥、.env 文件内容等会被明文记录）"
echo ""
if ! ask_confirm "确认理解并继续？" "y"; then
    msg_info "已取消操作。"
    exit 0
fi

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

{
    write_header "$output_file" "$base_dir" "$timestamp"
    write_tree "$output_file" "$base_dir"
    write_file_contents "$output_file" "$base_dir"
} || {
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

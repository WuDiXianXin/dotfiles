#!/bin/bash

# 捕获 Ctrl+C，优雅退出
trap 'echo ""; echo "操作已取消。"; exit 0' INT

# ==================== 用户交互 ====================
echo -n "请输入要备份的目录路径（支持 ~，例如 ~/.config/nvim，直接回车备份当前目录）: "
read input_dir

if [ -z "$input_dir" ]; then
    echo -n "未输入路径，是否备份当前目录（$(pwd)）？(y/N): "
    read confirm
    [[ "$confirm" =~ ^[Yy]$ ]] || { echo "已取消操作。"; exit 0; }
    base_dir="$(pwd)"
else
    base_dir="${input_dir/#\~/$HOME}"
fi

[ -d "$base_dir" ] || { echo "错误：目录不存在 -> $base_dir"; exit 1; }

# ==================== 最终安全确认 ====================
echo
echo "⚠️  注意：备份文件包含所有文件原始内容，请勿直接分享包含敏感信息的备份！"
echo "   （如 API 密钥、私钥、.env 文件、日志等会被明文记录）"
echo
echo -n "确认理解并继续？(Y/n): "
read final_confirm
[[ "$final_confirm" =~ ^[Nn]$ ]] && { echo "已取消操作。"; exit 0; }

# ==================== 确认后定义排除并检查工具 ====================
EXCLUDE_DIRS=( .git node_modules __pycache__ target tmp temp cache .cache dist build vendor )
EXCLUDE_FILES=( .env .env.local '*.log' )

# 生成排除参数
build_find_exclude() {
    local excludes=""
    for dir in "${EXCLUDE_DIRS[@]}"; do
        excludes="$excludes ! -path '*/$dir/*'"
    done
    for file in "${EXCLUDE_FILES[@]}"; do
        excludes="$excludes ! -name '$file'"
    done
    echo "$excludes"
}

build_fd_exclude() {
    local excludes=""
    for dir in "${EXCLUDE_DIRS[@]}"; do
        excludes="$excludes --exclude '$dir'"
    done
    for file in "${EXCLUDE_FILES[@]}"; do
        excludes="$excludes --exclude '$file'"
    done
    echo "$excludes"
}

build_tree_ignore() {
    IFS='|'; echo "${EXCLUDE_DIRS[*]}"; unset IFS
}

build_eza_ignore() {
    IFS=','; echo "{${EXCLUDE_DIRS[*]}}"; unset IFS
}

# 检查工具并统一选择
USE_FD=$(command -v fd >/dev/null 2>&1 && echo true || echo false)
USE_EZA=$(command -v eza >/dev/null 2>&1 && echo true || echo false)
USE_EXA=$(command -v exa >/dev/null 2>&1 && echo true || echo false)
USE_TREE=$(command -v tree >/dev/null 2>&1 && echo true || echo false)

# ==================== 文件数量扫描 ====================
echo "正在统计文件数量..."
if $USE_FD; then
    FD_EXCLUDE=$(build_fd_exclude)
    file_count=$(eval fd --type f --hidden $FD_EXCLUDE '.' "\"$base_dir\"" | wc -l)
else
    FIND_EXCLUDE=$(build_find_exclude)
    file_count=$(eval find "\"$base_dir\"" -type f $FIND_EXCLUDE | wc -l)
fi

echo "目录中约包含 $file_count 个文件（已自动排除 .git、node_modules、target、tmp、cache 等）。"
if [ "$file_count" -gt 300 ]; then
    echo "⚠️  文件数量较多（>$file_count），备份文件可能很大。"
    echo -n "是否继续？(y/N): "
    read confirm_large
    [[ "$confirm_large" =~ ^[Yy]$ ]] || { echo "已取消操作。"; exit 0; }
fi

# ==================== 同意后执行备份 ====================
timestamp=$(date +'%Y%m%d-%H%M%S')
if [ -d "$HOME/Desktop" ]; then
    output_file="$HOME/Desktop/dir-backup-$timestamp.txt"
elif [ -d "$HOME/桌面" ]; then
    output_file="$HOME/桌面/dir-backup-$timestamp.txt"
else
    output_file="./dir-backup-$timestamp.txt"
fi

echo
echo "正在备份: $base_dir"
echo "输出文件: $output_file"
echo

# 写入头部 + 目录树
{
    echo "配置目录完整备份"
    echo "生成时间: $(date +'%Y-%m-%d %H:%M:%S')"
    echo "源目录: $base_dir"
    echo
    echo "目录结构："
    echo "----------------------------------------"

    if $USE_EZA; then
        EZA_IGNORE=$(build_eza_ignore)
        eza -T -a --color=never --ignore-glob="$EZA_IGNORE" "$base_dir" 2>/dev/null \
            || eza -T -a --color=never "$base_dir"
    elif $USE_EXA; then
        exa --tree -a --color=never "$base_dir"
    elif $USE_TREE; then
        TREE_IGNORE=$(build_tree_ignore)
        tree -a --charset ascii -I "$TREE_IGNORE" "$base_dir"
    else
        echo "(未安装 eza/exa/tree，无法显示美观目录树)"
    fi

    echo
    echo "==========================================="
    echo
    echo
} > "$output_file"

# 遍历文件内容
if $USE_FD; then
    eval fd --type f --hidden $FD_EXCLUDE '.' "\"$base_dir\"" | sort | while read -r full_path; do
        rel_path="${full_path#$base_dir/}"
        {
            echo "文件路径: $rel_path"
            echo "----------------------------------------"
            cat "$full_path"
            echo
            echo "========================================"
            echo
            echo
        } >> "$output_file"
    done
else
    eval find "\"$base_dir\"" -type f $FIND_EXCLUDE | sort | while read -r full_path; do
        rel_path="${full_path#$base_dir/}"
        {
            echo "文件路径: $rel_path"
            echo "----------------------------------------"
            cat "$full_path"
            echo
            echo "========================================"
            echo
            echo
        } >> "$output_file"
    done
fi

echo "✅ 备份完成！"
echo "文件已保存到: $output_file"
echo "建议命令打开: nvim \"$output_file\""

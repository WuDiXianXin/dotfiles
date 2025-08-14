#!/bin/bash

# 截图脚本 - 支持全屏和区域截图，自动保存到 ~/Pictures/screenshots

# 配置
SAVE_DIR="$HOME/Pictures/screenshots"
DATE_FORMAT="%Y%m%d_%H%M%S"
FILE_PREFIX="screenshot"
DEFAULT_FORMAT="png"

# 确保保存目录存在
mkdir -p "$SAVE_DIR"

# 生成保存路径
generate_filename() {
  local format="${1:-$DEFAULT_FORMAT}"
  echo "$SAVE_DIR/${FILE_PREFIX}_$(date +"$DATE_FORMAT").$format"
}

# 错误处理
handle_error() {
  notify-send -u critical "截图失败" "$1"
  exit 1
}

# 全屏截图
fullscreen() {
  local output_file=$(generate_filename)
  grim "$output_file" || handle_error "无法保存全屏截图"
  notify-send "已截取全屏" "已保存到 $output_file"
}

# 区域截图
region() {
  local output_file=$(generate_filename)
  local geometry=$(slurp) || handle_error "未选择区域"
  grim -g "$geometry" "$output_file" || handle_error "无法保存区域截图"
  notify-send "已截取区域" "已保存到 $output_file"
}

# 帮助信息
show_help() {
  echo "用法: $0 [选项]"
  echo "选项:"
  echo "  -f, --fullscreen   全屏截图"
  echo "  -r, --region       区域截图"
  echo "  -h, --help         显示此帮助信息"
}

# 主逻辑
case "$1" in
-f | --fullscreen)
  fullscreen
  ;;
-r | --region)
  region
  ;;
-h | --help)
  show_help
  ;;
*)
  echo "错误: 未知选项"
  show_help
  exit 1
  ;;
esac

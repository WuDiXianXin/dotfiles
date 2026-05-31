#!/usr/bin/env bash
set -euo pipefail # 严格模式：出错退出、未定义变量报错、管道失败也报错

# ──────────────────────────────────────────────
#                     配置区
# ──────────────────────────────────────────────

SAVE_DIR="${HOME}/Pictures/Screenshots" # 截图保存目录
mkdir -p "$SAVE_DIR"                    # 确保目录存在，不存在则创建

FILE_PREFIX="shot"   # 截图文件名前缀
DEFAULT_FORMAT="png" # 默认图片格式（用于文件名后缀）

# slurp 区域选择参数（绘制矩形框的样式）
SLURP_SELECTION_ARGS=(
  -d             # 显示提示文字（尺寸等）
  -c '#ff5555ff' # 边框颜色（红，带alpha）
  -b '#00000088' # 背景遮罩颜色（半透明黑）
  -s '#ff555533' # 选区填充颜色（半透明红）
  -w 3           # 边框宽度（像素）
)

# satty 标注工具基础参数
SATTY_BASE_ARGS=(
  --filename -                                           # 从标准输入读取图片数据
  --copy-command wl-copy                                 # 复制到剪贴板使用的命令（Wayland）
  --fullscreen                                           # 以全屏模式启动标注界面
  --initial-tool arrow                                   # 默认工具：箭头
  --actions-on-enter=save-to-file,save-to-clipboard,exit # 按回车后执行：保存文件、保存到剪贴板、退出
  --actions-on-escape=exit                               # 按ESC直接退出，不保存
  --brush-smooth-history-size 8                          # 平滑笔刷的历史记录大小
)

# grim 截图时是否包含光标（默认空=不包含光标；若需包含光标可设为 "-c"）
GRIM_CURSOR=()

# ──────────────────────────────────────────────
#                     函数
# ──────────────────────────────────────────────

# 错误处理函数：输出错误信息并退出
die() {
  echo "错误: $*" >&2
  exit 1
}

# 显示帮助信息
show_help() {
  cat <<EOF
用法: $(basename "$0") [选项]

选项:
  -f, --fullscreen, full     全屏截图
  -r, --region, region       区域截图
  -h, --help                 帮助
EOF
  exit 0
}

# 检查依赖程序是否已安装
check_deps() {
  local missing=()
  for cmd in grim slurp satty; do
    command -v "$cmd" >/dev/null 2>&1 || missing+=("$cmd")
  done
  if ((${#missing[@]} > 0)); then
    die "缺少必要程序：${missing[*]}"
  fi
}

# 核心截图函数：调用 grim 截图并通过管道传递给 satty 标注
# 参数 $1: 几何描述字符串（如 "1920,1080 2560x1440" 或空字符串代表全屏）
take_screenshot() {
  local geom="$1"
  # 生成带时间戳的输出文件名
  local outfile="${SAVE_DIR}/${FILE_PREFIX}_$(date +%Y%m%d_%H%M%S).${DEFAULT_FORMAT}"
  # 构建 satty 命令参数，包含输出文件名
  local satty_args=("${SATTY_BASE_ARGS[@]}" --output-filename "$outfile")

  if [[ -n $geom ]]; then
    # 指定几何区域截图：grim 捕获该区域，输出 ppm 格式给 satty
    grim "${GRIM_CURSOR[@]}" -g "$geom" -t ppm - | satty "${satty_args[@]}" || die "截图失败"
  else
    # 全屏截图：先短暂延迟（避免松开快捷键时界面抖动），然后全屏捕获
    sleep 0.2
    grim "${GRIM_CURSOR[@]}" -t ppm - | satty "${satty_args[@]}" || die "全屏截图失败"
  fi
}

# ──────────────────────────────────────────────
#                     主逻辑
# ──────────────────────────────────────────────

# 检查依赖
check_deps

# 解析命令行参数，确定截图模式
case "${1:-}" in
-f | --fullscreen | full | fullscreen | f) MODE="full" ;;
-r | --region | region | r) MODE="region" ;;
-h | --help | help) show_help ;;
*) MODE="region" ;; # 默认模式：区域截图
esac

# 根据模式执行相应操作
case "$MODE" in
full)
  # 全屏模式：调用 take_screenshot 并传入空几何参数
  take_screenshot ""
  ;;
region | *)
  # 区域模式：使用 slurp 交互式选择区域，得到几何字符串
  GEOM=$(slurp "${SLURP_SELECTION_ARGS[@]}") || exit 0 # 用户取消则退出
  [[ -z "$GEOM" ]] && exit 0                           # 几何为空则退出
  take_screenshot "$GEOM"                              # 进行截图
  ;;
esac

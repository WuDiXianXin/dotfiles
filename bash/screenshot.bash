#!/usr/bin/env bash

set -euo pipefail

# ────────────────────────────────────────────────
#                     配置区
# ────────────────────────────────────────────────

SAVE_DIR="${HOME}/Pictures/Screenshots"
mkdir -p "$SAVE_DIR"

DATE_FORMAT="%Y%m%d_%H%M%S"
FILE_PREFIX="shot"
DEFAULT_FORMAT="png"

FILENAME="${SAVE_DIR}/${FILE_PREFIX}_$(date +"$DATE_FORMAT").${DEFAULT_FORMAT}"

# slurp 选区风格（2025–2026 社区流行配色示例）
SLURP_ARGS=(
    -d
    -c '#ff5555ff'      # 红色描边
    -b '#00000088'      # 半透黑背景
    -s '#ff555533'      # 选区半透红
    -w 3                # 稍粗边框，更易看清
    -o                  # 支持输出整个输出区
)

# satty 最新推荐参数（基于 v0.19+ 社区偏好）
SATTY_ARGS=(
    --filename -
    --output-filename "$FILENAME"
    --copy-command wl-copy
    # --early-exit
    --fullscreen                     # 占满屏幕，更现代
    --initial-tool arrow
    --actions-on-enter  "save-to-file,save-to-clipboard,exit"
    --actions-on-escape=exit       # Esc 只退出，不保存不复制（最常见需求）
    # --disable-notifications
    --brush-smooth-history-size 8    # 更平滑的笔迹
)

# 是否包含光标（很多人不喜欢默认开）
GRIM_CURSOR=""                  # 想要光标就改为 " --cursor "

# niri 支持（检测是否运行 niri）
USE_NIRI=false
if command -v niri >/dev/null 2>&1 && pgrep -x niri >/dev/null 2>&1; then
    USE_NIRI=true
fi

# niri 专用：是否显示光标（-p / --show-pointer）
NIRI_SHOW_POINTER=false         # true 显示光标，false 隐藏；改成你喜欢的
NIRI_POINTER_ARG=""
if $NIRI_SHOW_POINTER; then
    NIRI_POINTER_ARG="--show-pointer"
else
    NIRI_POINTER_ARG=""
fi

# ────────────────────────────────────────────────
#                     函数区
# ────────────────────────────────────────────────

notify_success() {
    notify-send -u low "截图已完成" \
        "已复制到剪贴板\n保存位置：${FILENAME}" || true
}

notify_error() {
    notify-send -u critical "截图失败" "${1:-未知错误}" || true
    exit 1
}

show_help() {
    cat <<EOF
用法: $(basename "$0") [选项]

选项:
  -f, --fullscreen, full     全屏截图（带 Satty 编辑）
  -r, --region, region       区域截图（带 Satty 编辑）
  -w, --window               当前窗口截图（Hyprland/Sway 支持）
  无参数                     默认区域截图
  -h, --help                 显示此帮助
EOF
    exit 0
}

# ────────────────────────────────────────────────
#                     主逻辑
# ────────────────────────────────────────────────

case "${1:-}" in
    -f|--fullscreen|full|fullscreen|f)   MODE="full" ;;
    -r|--region|region|r)                MODE="region" ;;
    -w|--window|window|w)                MODE="window" ;;
    -h|--help|help)                      show_help ;;
    *)                                   MODE="region" ;;
esac

case "$MODE" in
    full)
        # 全屏建议加一点延迟，避免自己按键被拍进去
        sleep 0.2 2>/dev/null || true
        grim ${GRIM_CURSOR} -t ppm - \
            | satty "${SATTY_ARGS[@]}" \
            || notify_error "全屏截图失败"
        ;;

    window)
        if $USE_NIRI; then
            # niri 原生窗口截图（焦点窗口）
            niri msg action screenshot-window $NIRI_POINTER_ARG --write-to-disk=false || notify_error "niri 窗口截图失败"

            sleep 0.5
            # 等待剪贴板出现图片（最多等 1 秒）
            for i in {1..20}; do
                if wl-paste --list-types 2>/dev/null | grep -q "image/png"; then
                    break
                fi
                sleep 0.05
            done

            if ! wl-paste --list-types 2>/dev/null | grep -q "image/png"; then
                notify_error "niri 未将截图复制到剪贴板（超时）"
                exit 1
            fi

            # 从剪贴板喂给 satty，并清空剪贴板（可选，避免残留）
            wl-paste --type image/png | satty "${SATTY_ARGS[@]}" \
                || notify_error "satty 编辑失败 (niri window)"

            # 可选：编辑完后清空剪贴板（很多人不喜欢截图残留在剪贴板）
            # wl-copy "" 2>/dev/null || true
        else
          if ! command -v hyprctl >/dev/null 2>&1 && ! command -v swaymsg >/dev/null 2>&1; then
              notify_error "窗口模式需要 hyprctl 或 swaymsg"
          fi

          if command -v hyprctl >/dev/null 2>&1; then
              # Hyprland
              pos=$(hyprctl activewindow -j | jq -r '.at | join(",")')
              size=$(hyprctl activewindow -j | jq -r '.size | join("x")')
              GEOM="${pos} ${size}"
          else
              # Sway
              GEOM=$(swaymsg -t get_tree | jq -r '.. | select(.focused? == true) | .rect | "\(.x),\(.y) \(.width)x\(.height)"')
          fi

          [[ -z "$GEOM" ]] && notify_error "无法获取活动窗口几何信息"

          grim ${GRIM_CURSOR} -g "$GEOM" -t ppm - \
              | satty "${SATTY_ARGS[@]}" \
              || notify_error "窗口截图失败"
        fi
        ;;

    region|*)
        GEOM=$(slurp "${SLURP_ARGS[@]}") || exit 0   # Esc 取消 → 静默退出
        [[ -z "$GEOM" ]] && exit 0

        grim ${GRIM_CURSOR} -g "$GEOM" -t ppm - \
            | satty "${SATTY_ARGS[@]}" \
            || notify_error "区域截图失败"
        ;;
esac

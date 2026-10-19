#!/usr/bin/env bash
# 关闭 NVIDIA 显卡直通 + 释放大页
# 用法: sudo ./disable-passthrough.sh [选项]
#   --vga ADDR       NVIDIA GPU PCI 地址，默认 0000:01:00.0
#   --audio ADDR     NVIDIA 音频 PCI 地址，默认 0000:01:00.1
#   -y, --yes        非交互自动确认
#   -n, --dry-run    只打印不执行
#   -h, --help       显示帮助
# 也可用环境变量 NVIDIA_VGA / NVIDIA_AUDIO 指定默认值。

set -euo pipefail

# ---------- 颜色 / 日志 ----------
if [[ -t 1 && -z ${NO_COLOR:-} ]]; then
    c_blue=$'\033[1;34m'; c_green=$'\033[1;32m'; c_yellow=$'\033[1;33m'
    c_red=$'\033[1;31m'; c_reset=$'\033[0m'
else
    c_blue=; c_green=; c_yellow=; c_red=; c_reset=
fi
log()  { printf '%s[*]%s %s\n' "$c_blue"   "$c_reset" "$*" >&2; }
ok()   { printf '%s[+]%s %s\n' "$c_green"  "$c_reset" "$*" >&2; }
warn() { printf '%s[!]%s %s\n' "$c_yellow" "$c_reset" "$*" >&2; }
err()  { printf '%s[-]%s %s\n' "$c_red"    "$c_reset" "$*" >&2; }
die()  { err "$*"; exit 1; }

usage() {
    cat <<'EOF'
用法: sudo ./disable-passthrough.sh [选项]
  --vga ADDR       NVIDIA GPU PCI 地址，默认 0000:01:00.0
  --audio ADDR     NVIDIA 音频 PCI 地址，默认 0000:01:00.1
  -y, --yes        非交互自动确认
  -n, --dry-run    只打印不执行
  -h, --help       显示本帮助

也可通过环境变量 NVIDIA_VGA / NVIDIA_AUDIO 指定。
EOF
}

# ---------- 默认值 / 参数 ----------
NVIDIA_VGA="${NVIDIA_VGA:-0000:01:00.0}"
NVIDIA_AUDIO="${NVIDIA_AUDIO:-0000:01:00.1}"
ASSUME_YES=0
DRY_RUN=0

while (($#)); do
    case "$1" in
        --vga)     [[ $# -ge 2 ]] || die "--vga 需要一个参数";   NVIDIA_VGA=$2;   shift 2 ;;
        --audio)   [[ $# -ge 2 ]] || die "--audio 需要一个参数"; NVIDIA_AUDIO=$2; shift 2 ;;
        --vga=*)   NVIDIA_VGA=${1#*=};   shift ;;
        --audio=*) NVIDIA_AUDIO=${1#*=}; shift ;;
        -y|--yes)      ASSUME_YES=1; shift ;;
        -n|--dry-run)  DRY_RUN=1;    shift ;;
        -h|--help)     usage; exit 0 ;;
        --)            shift; break ;;
        -*)            die "未知选项：$1（--help 查看用法）" ;;
        *)             die "多余参数：$1" ;;
    esac
done

# ---------- 工具函数 ----------
require_cmd() { command -v "$1" >/dev/null 2>&1 || die "缺少命令：$1（$2）"; }
module_loaded() { [[ -d /sys/module/$1 ]]; }

get_driver() {
    local link="/sys/bus/pci/devices/$1/driver"
    [[ -L "$link" ]] || { echo ""; return; }
    basename "$(readlink "$link")"
}

clear_driver_override() {
    local dev=$1 ov cur
    ov="/sys/bus/pci/devices/$dev/driver_override"
    [[ -e "$ov" ]] || { warn "  $dev 无 driver_override，跳过"; return 0; }
    cur=$(cat "$ov" 2>/dev/null || true)
    if [[ -z "$cur" || "$cur" == "(null)" ]]; then
        log "  $dev 的 driver_override 已为空，跳过"
        return 0
    fi 
    if (( DRY_RUN )); then
        log "  [dry-run] 清空 $dev 的 driver_override（当前：$cur）"
        return 0
    fi
    if printf '\n' > "$ov" 2>/dev/null; then
        ok "  清空 $dev 的 driver_override（原值：$cur）"
    else
        warn "  清空 $dev 的 driver_override 失败"
    fi
}

# ---------- 前置检查 ----------
[[ $EUID -eq 0 ]] || die "请用 root 运行：sudo $0"
require_cmd modprobe "kmod"
require_cmd pgrep    "procps"
require_cmd sysctl   "procps"
require_cmd fuser    "psmisc"

[[ $NVIDIA_VGA   =~ ^[0-9a-fA-F]{4}:[0-9a-fA-F]{2}:[0-9a-fA-F]{2}\.[0-7]$ ]] \
    || die "VGA BDF 格式错误：$NVIDIA_VGA"
[[ $NVIDIA_AUDIO =~ ^[0-9a-fA-F]{4}:[0-9a-fA-F]{2}:[0-9a-fA-F]{2}\.[0-7]$ ]] \
    || die "音频 BDF 格式错误：$NVIDIA_AUDIO"

for dev in "$NVIDIA_VGA" "$NVIDIA_AUDIO"; do
    [[ -d "/sys/bus/pci/devices/$dev" ]] || die "PCI 设备不存在：$dev"
done

log "配置：VGA=$NVIDIA_VGA  AUDIO=$NVIDIA_AUDIO"
(( DRY_RUN )) && warn "dry-run 模式：不执行破坏性操作"

log "当前驱动绑定："
for dev in "$NVIDIA_VGA" "$NVIDIA_AUDIO"; do
    log "  $dev -> $(get_driver "$dev" | sed 's/^$/(未绑定)/')"
done

# ---------- 0. 检查 VM / vfio 占用 ----------
log "检查是否有 QEMU 虚拟机或 vfio 用户 ..."
qemu_procs=$(pgrep -af 'qemu-system-' || true)
if [[ -n "$qemu_procs" ]]; then
    warn "检测到 qemu 进程："
    printf '%s\n' "$qemu_procs" | sed 's/^/    /' >&2
    warn "一定要先关闭使用直通的虚拟机，否则宿主机可能卡死！"
    if (( DRY_RUN )); then
        warn "[dry-run] 检测到 qemu，真跑会被拒绝；dry-run 仅预览到此处"
        exit 0
    fi
    if (( ASSUME_YES )); then
        ans=y
    elif [[ -t 0 ]]; then
        read -rp "已确认虚拟机已关闭，继续？[y/N] " ans || ans=n
    else
        die "非交互环境且未指定 -y，检测到 qemu 拒绝继续"
    fi
    [[ "$ans" =~ ^[Yy]$ ]] || die "已取消"
else
    ok "未发现 qemu-system 进程"
fi

# 再检查 /dev/vfio/分组是否还有进程打开（vlans 直通时典型情况）
shopt -s nullglob
vfio_groups=(/dev/vfio/[0-9]*)
shopt -u nullglob
if ((${#vfio_groups[@]})); then
    if fuser -s "${vfio_groups[@]}" 2>/dev/null; then
        warn "有进程仍打开 vfio 分组设备："
        fuser -v "${vfio_groups[@]}" 2>&1 | sed 's/^/    /' >&2 || true
        if (( DRY_RUN )); then
            warn "[dry-run] 真跑会被拒绝，请先关闭相关进程"
            exit 0
        fi
        if (( ASSUME_YES )); then
            ans=y
        elif [[ -t 0 ]]; then
            read -rp "仍要继续？[y/N] " ans || ans=n
        else
            die "非交互环境且未指定 -y，有进程占用 vfio 分组"
        fi
        [[ "$ans" =~ ^[Yy]$ ]] || die "已取消"
    else
        ok "vfio 分组设备未被占用"
    fi
fi

# ---------- 1. 从 vfio-pci 解绑 ----------
log "从 vfio-pci 解绑 ..."
for dev in "$NVIDIA_VGA" "$NVIDIA_AUDIO"; do
    cur=$(get_driver "$dev")
    if [[ "$cur" == "vfio-pci" ]]; then
        if (( DRY_RUN )); then
            log "  [dry-run] unbind $dev from vfio-pci"
        elif echo "$dev" > /sys/bus/pci/drivers/vfio-pci/unbind 2>/dev/null; then
            ok "  unbind vfio-pci $dev"
        else
            warn "  unbind vfio-pci $dev 失败"
        fi
    else
        log "  $dev 当前驱动为 ${cur:-（未绑定）}，跳过 unbind"
    fi
    clear_driver_override "$dev"
done

# ---------- 2. 重新加载 NVIDIA 模块 ----------
log "确保 NVIDIA 内核模块已加载（按依赖顺序）..."
# 顺序很重要：modeset 要先于 drm
for m in nvidia nvidia_modeset nvidia_drm nvidia_uvm nvidia_wmi_ec_backlight; do
    if module_loaded "$m"; then
        ok "  $m 已加载"
        continue
    fi
    if (( DRY_RUN )); then
        log "  [dry-run] modprobe $m"
        continue
    fi
    if modprobe "$m" 2>/dev/null; then
        ok "  modprobe $m"
    else
        # 某些平台没有 nvidia_wmi_ec_backlight / 非必须模块，降低为提示
        case "$m" in
            nvidia|nvidia_modeset|nvidia_drm)
                warn "  modprobe $m 失败（可稍后查看：dmesg | tail）" ;;
            *)
                log "  modprobe $m 失败（该模块可选，忽略）" ;;
        esac
    fi
done

# 确保音频驱动可用，否则 probe 时没人接管
if ! module_loaded snd_hda_intel; then
    if (( DRY_RUN )); then
        log "  [dry-run] modprobe snd_hda_intel"
    else
        modprobe snd_hda_intel 2>/dev/null && ok "  modprobe snd_hda_intel" \
            || warn "  modprobe snd_hda_intel 失败"
    fi
fi

# ---- 2.5 唤醒 GPU，避免 RTD3 下 probe 失败 ----
for dev in "$NVIDIA_VGA" "$NVIDIA_AUDIO"; do
    pc="/sys/bus/pci/devices/$dev/power/control"
    [[ -e "$pc" ]] || continue
    if (( DRY_RUN )); then
        log "  [dry-run] echo on > $pc"
    else
        echo on > "$pc" 2>/dev/null && ok "  $dev power/control=on" \
            || warn "  $dev power/control 设置失败"
    fi
done

# ---------- 3. 重新探测设备 ----------
log "重新探测设备 ..."
if (( DRY_RUN )); then
    log "  [dry-run] probe $NVIDIA_VGA / $NVIDIA_AUDIO"
else
    for dev in "$NVIDIA_VGA" "$NVIDIA_AUDIO"; do
        if echo "$dev" > /sys/bus/pci/drivers_probe 2>/dev/null; then
            ok "  probe $dev"
        else
            warn "  probe $dev 失败"
        fi
    done
fi

# ---------- 4. 校验绑定 ----------
log "校验驱动绑定："
bind_fail=0
if (( DRY_RUN )); then
    log "  [dry-run] 跳过校验（真跑才会重新绑定驱动）"
else
    for dev in "$NVIDIA_VGA" "$NVIDIA_AUDIO"; do
        cur=$(get_driver "$dev")
        case "$dev" in
            "$NVIDIA_VGA")
                if [[ "$cur" == "nvidia" ]]; then
                    ok "  $dev -> nvidia"
                else
                    warn "  $dev -> ${cur:-（未绑定）}（期望 nvidia）"
                    bind_fail=1
                fi ;;
            "$NVIDIA_AUDIO")
                if [[ "$cur" == "snd_hda_intel" ]]; then
                    ok "  $dev -> snd_hda_intel"
                else
                    warn "  $dev -> ${cur:-（未绑定）}（期望 snd_hda_intel）"
                    bind_fail=1
                fi ;;
        esac
    done

    if (( bind_fail != 0 )); then
        warn "部分设备未回到宿主机驱动，可查看：dmesg | tail -50"
    fi
fi

if (( ! DRY_RUN )) && (( bind_fail == 0 )) && command -v nvidia-smi >/dev/null 2>&1; then
    smi_ok=0
    for _ in 1 2 3 4 5; do
        if nvidia-smi -L >/dev/null 2>&1; then smi_ok=1; break; fi
        sleep 1
    done
    if (( smi_ok )); then
        ok "nvidia-smi 可正常枚举 GPU"
    else
        warn "nvidia-smi 失败，请检查：dmesg | grep -i -E 'nvidia|gsp'"
    fi
fi

# ---------- 5. 释放大页 ----------
log "释放大页 ..."
hp_total=$(awk '/^HugePages_Total:/ {print $2}' /proc/meminfo)
hp_free=$(awk  '/^HugePages_Free:/  {print $2}' /proc/meminfo)
: "${hp_total:=0}" "${hp_free:=0}"
in_use=$(( hp_total - hp_free ))

if (( in_use > 0 )); then
    warn "有 $in_use 个大页仍在使用中（HugePages_Free=$hp_free / Total=$hp_total）"
    warn "请先关闭使用大页的进程（通常是 QEMU），否则释放不会完全生效"
fi

if (( DRY_RUN )); then
    log "  [dry-run] sysctl -w vm.nr_hugepages=0"
else
    sysctl -w vm.nr_hugepages=0 >/dev/null || warn "sysctl 设置返回非零"
    hp=$(cat /proc/sys/vm/nr_hugepages 2>/dev/null || echo 0)
    if (( hp == 0 )); then
        ok "nr_hugepages = 0（大页已释放）"
    else
        warn "nr_hugepages = $hp（未归零，可能仍有进程占用）"
    fi
fi

if (( DRY_RUN )); then
    log "[dry-run] 预览结束（未实际解绑 / 重载 / 释放大页）"
elif (( bind_fail == 0 )); then
    ok "直通已关闭，N 卡已归还宿主机"
    warn "niri 若配置了 ignore-drm-device，需要改回配置或重启 niri-session 才能重新使用 N 卡"
else
    warn "直通关闭未完全成功：部分设备仍不在宿主机驱动上"
    warn "请检查：lspci -Dk -s $NVIDIA_VGA -s $NVIDIA_AUDIO"
    warn "以及：dmesg | grep -i -E 'nvidia|vfio|gsp' | tail -50"
fi

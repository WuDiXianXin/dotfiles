#!/usr/bin/env bash
# 开启 NVIDIA 显卡直通 + 分配大页
# 用法: sudo ./enable-passthrough.sh [选项]
#   --vga ADDR       NVIDIA GPU PCI 地址，默认 0000:01:00.0
#   --audio ADDR     NVIDIA 音频 PCI 地址，默认 0000:01:00.1
#   --hugepages N    2MB 大页数量，默认 4096
#   -y, --yes        非交互自动确认
#   -n, --dry-run    只打印不执行
#   -h, --help       显示帮助
# 也可用环境变量 NVIDIA_VGA / NVIDIA_AUDIO / HUGEPAGES 指定默认值。

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
用法: sudo ./enable-passthrough.sh [选项]
  --vga ADDR       NVIDIA GPU PCI 地址，默认 0000:01:00.0
  --audio ADDR     NVIDIA 音频 PCI 地址，默认 0000:01:00.1
  --hugepages N    2MB 大页数量，默认 4096
  -y, --yes        非交互自动确认
  -n, --dry-run    只打印不执行
  -h, --help       显示本帮助

也可通过环境变量 NVIDIA_VGA / NVIDIA_AUDIO / HUGEPAGES 指定。
EOF
}

# ---------- 默认值 / 参数 ----------
NVIDIA_VGA="${NVIDIA_VGA:-0000:01:00.0}"
NVIDIA_AUDIO="${NVIDIA_AUDIO:-0000:01:00.1}"
HUGEPAGES="${HUGEPAGES:-4096}"

ASSUME_YES=0
DRY_RUN=0

while (($#)); do
    case "$1" in
        --vga)         [[ $# -ge 2 ]] || die "--vga 需要一个参数";       NVIDIA_VGA=$2;   shift 2 ;;
        --audio)       [[ $# -ge 2 ]] || die "--audio 需要一个参数";     NVIDIA_AUDIO=$2; shift 2 ;;
        --hugepages)   [[ $# -ge 2 ]] || die "--hugepages 需要一个参数"; HUGEPAGES=$2;    shift 2 ;;
        --vga=*)       NVIDIA_VGA=${1#*=};   shift ;;
        --audio=*)     NVIDIA_AUDIO=${1#*=}; shift ;;
        --hugepages=*) HUGEPAGES=${1#*=};    shift ;;
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

unbind_device() {
    local dev=$1 drv
    drv=$(get_driver "$dev")
    if [[ -z "$drv" ]]; then
        log "  $dev 未绑定任何驱动"
        return 0
    fi
    if (( DRY_RUN )); then
        log "  [dry-run] unbind $dev from $drv"
        return 0
    fi
    if echo "$dev" > "/sys/bus/pci/drivers/$drv/unbind" 2>/dev/null; then
        ok "  unbind $dev from $drv"
    else
        warn "  unbind $dev from $drv 失败"
    fi
}

# ---------- 前置检查 ----------
[[ $EUID -eq 0 ]] || die "请用 root 运行：sudo $0"

require_cmd modprobe "kmod"
require_cmd lsmod    "kmod"
require_cmd fuser    "psmisc"
require_cmd sysctl   "procps"

[[ $HUGEPAGES =~ ^[0-9]+$ ]] && (( HUGEPAGES > 0 )) \
    || die "HUGEPAGES 必须为正整数：$HUGEPAGES"
[[ $NVIDIA_VGA   =~ ^[0-9a-fA-F]{4}:[0-9a-fA-F]{2}:[0-9a-fA-F]{2}\.[0-7]$ ]] \
    || die "VGA BDF 格式错误：$NVIDIA_VGA"
[[ $NVIDIA_AUDIO =~ ^[0-9a-fA-F]{4}:[0-9a-fA-F]{2}:[0-9a-fA-F]{2}\.[0-7]$ ]] \
    || die "音频 BDF 格式错误：$NVIDIA_AUDIO"

for dev in "$NVIDIA_VGA" "$NVIDIA_AUDIO"; do
    [[ -d "/sys/bus/pci/devices/$dev" ]] || die "PCI 设备不存在：$dev"
done

log "配置：VGA=$NVIDIA_VGA  AUDIO=$NVIDIA_AUDIO  HUGEPAGES=$HUGEPAGES"
(( DRY_RUN )) && warn "dry-run 模式：不执行破坏性操作"

# IOMMU 检查（软性）
if [[ -d /sys/kernel/iommu_groups ]] && [[ -n $(ls -A /sys/kernel/iommu_groups 2>/dev/null || true) ]]; then
    ok "检测到 IOMMU 分组"
else
    warn "未发现 IOMMU 分组，请确认 BIOS 已开 VT-d/AMD-Vi，内核参数含 intel_iommu=on 或 amd_iommu=on"
fi

for dev in "$NVIDIA_VGA" "$NVIDIA_AUDIO"; do
    if [[ -L "/sys/bus/pci/devices/$dev/iommu_group" ]]; then
        gid=$(basename "$(readlink -f "/sys/bus/pci/devices/$dev/iommu_group")")
        log "  $dev -> IOMMU group $gid"
    fi
done

log "当前 DRM 渲染设备："
shopt -s nullglob
for p in /sys/class/drm/render*/device/driver; do
    [[ -L "$p" ]] && log "  $p -> $(basename "$(readlink "$p")")"
done
shopt -u nullglob

# 提示：设备可能已经处于直通状态（幂等检查）
cur_vga=$(get_driver "$NVIDIA_VGA")
cur_aud=$(get_driver "$NVIDIA_AUDIO")
log "当前驱动：$NVIDIA_VGA -> ${cur_vga:-（未绑定）}，$NVIDIA_AUDIO -> ${cur_aud:-（未绑定）}"
if [[ "$cur_vga" == "vfio-pci" && "$cur_aud" == "vfio-pci" ]]; then
    log "两个设备均已在 vfio-pci 上，直通似乎已开启；本次执行幂等"
fi

# ---------- 1. 终止占用进程 ----------
log "检查占用 NVIDIA 设备的进程 ..."
shopt -s nullglob
nv_devs=(/dev/nvidia*)
shopt -u nullglob

if ((${#nv_devs[@]})); then
    rc=0
    fuser -s "${nv_devs[@]}" 2>/dev/null || rc=$?
    case $rc in
        0)
            warn "以下进程正在占用 N 卡："
            fuser -v "${nv_devs[@]}" 2>&1 | sed 's/^/    /' >&2 || true
            if (( DRY_RUN )); then
                log "[dry-run] 将 kill -9 上述进程"
            else
                if (( ASSUME_YES )); then
                    ans=y
                elif [[ -t 0 ]]; then
                    read -rp "kill -9 掉它们？[y/N] " ans || ans=n
                else
                    die "非交互环境且未指定 -y，拒绝 kill 进程"
                fi
                [[ "$ans" =~ ^[Yy]$ ]] || die "已取消"
                fuser -k -9 "${nv_devs[@]}" || warn "fuser kill 返回非零"
                sleep 1
            fi
            ;;
        1) ok "无进程占用" ;;
        *) warn "fuser 返回码 $rc，继续" ;;
    esac
else
    log "/dev/nvidia* 不存在，跳过"
fi

# 设备已绑 vfio-pci 时，QEMU 持有的是 /dev/vfio/N，不是 /dev/nvidia*
shopt -s nullglob
vfio_groups=(/dev/vfio/[0-9]*)
shopt -u nullglob
if ((${#vfio_groups[@]})); then
    if fuser -s "${vfio_groups[@]}" 2>/dev/null; then
        warn "有进程仍打开 vfio 分组设备（VM 可能正在使用直通）："
        fuser -v "${vfio_groups[@]}" 2>&1 | sed 's/^/    /' >&2 || true
        if (( DRY_RUN )); then
            warn "[dry-run] 真跑会被拒绝，请先关闭 VM"
            exit 0
        fi
        if (( ASSUME_YES )); then
            die "检测到 VM/进程占用 vfio 分组，拒绝继续"
        elif [[ -t 0 ]]; then
            read -rp "确认已关闭 VM，继续？[y/N] " ans || ans=n
            [[ "$ans" =~ ^[Yy]$ ]] || die "已取消"
        else
            die "非交互环境且未指定 -y，有进程占用 vfio 分组"
        fi
    else
        ok "vfio 分组设备未被占用"
    fi
fi

# ---- 1.6 处理 nvidia_drm.fbdev 导致的 fbcon 占用 ----
nvdrm_fbdev=$(cat /sys/module/nvidia_drm/parameters/fbdev 2>/dev/null || echo "N")
if [[ "$nvdrm_fbdev" == "Y" ]]; then
    warn "nvidia_drm.fbdev=Y，fbcon 可能绑定 N 卡 framebuffer"
    unbound=0
    for vc in /sys/class/vtconsole/vtcon*; do
        [[ -e "$vc/name" ]] || continue
        name=$(cat "$vc/name" 2>/dev/null || true)
        [[ "$name" == *"frame buffer device"* ]] || continue
        bind=$(cat "$vc/bind" 2>/dev/null || echo 1)
        [[ "$bind" == "1" ]] || continue
        if (( DRY_RUN )); then
            log "  [dry-run] echo 0 > $vc/bind"
            continue
        fi
        if echo 0 > "$vc/bind" 2>/dev/null; then
            ok "  解绑 fbcon: $vc"
            unbound=1
        else
            warn "  解绑 fbcon 失败: $vc"
        fi
    done
    if (( unbound )); then
        warn "已解绑 fbcon：切到其他 VT 会黑屏（切回图形会话不受影响）"
    fi
    warn "若 rmmod nvidia_drm 仍失败，请先切到非图形 VT：Ctrl+Alt+F2，或 systemctl isolate multi-user.target"
fi

# ---------- 2. 卸载 NVIDIA 内核模块 ----------
log "按顺序移除 NVIDIA 内核模块 ..."
for m in nvidia_wmi_ec_backlight nvidia_drm nvidia_uvm nvidia_modeset nvidia; do
    if ! module_loaded "$m"; then
        log "  模块 $m 未加载，跳过"
        continue
    fi
    if (( DRY_RUN )); then
        log "  [dry-run] rmmod $m"
        continue
    fi
    if rmmod "$m" 2>/dev/null; then
        ok "  rmmod $m"
    else
        sleep 1
        if rmmod "$m" 2>/dev/null; then
            ok "  rmmod $m（重试成功）"
        else
            warn "  rmmod $m 失败（可能仍被占用）"
        fi
    fi
done

if module_loaded nvidia; then
    err "nvidia 模块仍在使用，当前相关模块："
    lsmod | awk 'NR==1 || $1 ~ /^(nvidia|drm|snd_hda)/' >&2 || true
    die "请排查占用后重试"
fi

# ---- 2.5 唤醒 GPU，避免 RTD3 下 vfio probe 失败 ----
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

# ---------- 3. 从原驱动解绑 ----------
cur_vga_drv=$(get_driver "$NVIDIA_VGA")
cur_aud_drv=$(get_driver "$NVIDIA_AUDIO")
if [[ "$cur_vga_drv" == "vfio-pci" && "$cur_aud_drv" == "vfio-pci" ]]; then
    log "设备已绑定 vfio-pci，跳过解绑"
else
    log "从当前驱动解绑设备 ..."
    unbind_device "$NVIDIA_VGA"
    unbind_device "$NVIDIA_AUDIO"
fi

# ---------- 4. vfio-pci 接管 ----------
if [[ "$cur_vga_drv" == "vfio-pci" && "$cur_aud_drv" == "vfio-pci" ]]; then
    log "设备已由 vfio-pci 接管，跳过"
elif (( DRY_RUN )); then
    log "让 vfio-pci 接管 ..."
    log "  [dry-run] modprobe vfio-pci / vfio_iommu_type1"
    log "  [dry-run] 写 driver_override + drivers_probe"
else
    log "让 vfio-pci 接管 ..."
    modprobe vfio-pci           || die "modprobe vfio-pci 失败"
    modprobe vfio_iommu_type1 2>/dev/null || true

    for dev in "$NVIDIA_VGA" "$NVIDIA_AUDIO"; do
        ov="/sys/bus/pci/devices/$dev/driver_override"
        [[ -e "$ov" ]] || die "$dev 缺少 driver_override（内核过旧？）"
        printf 'vfio-pci\n' > "$ov" || die "写入 driver_override 失败：$dev"
        echo "$dev" > /sys/bus/pci/drivers_probe 2>/dev/null \
            || warn "probe $dev 失败"
    done
fi

# ---------- 5. 校验绑定 ----------
log "校验绑定（应为 vfio-pci）："
bind_fail=0
if (( DRY_RUN )); then
    log "  [dry-run] 跳过校验（真跑才会重新绑定驱动）"
else
    for dev in "$NVIDIA_VGA" "$NVIDIA_AUDIO"; do
        drv=$(get_driver "$dev")
        if [[ "$drv" == "vfio-pci" ]]; then
            ok "  $dev -> vfio-pci"
        else
            err "  $dev -> ${drv:-（未绑定）}"
            bind_fail=1
        fi
    done
    (( bind_fail == 0 )) || die "绑定校验失败，可查看：dmesg | tail"
fi

# ---------- 6. 分配大页 ----------
if (( DRY_RUN )); then
    log "[dry-run] 跳过分配大页，预览结束"
    exit 0
fi

cur_hp=$(cat /proc/sys/vm/nr_hugepages 2>/dev/null || echo 0)
if (( cur_hp >= HUGEPAGES )); then
    ok "大页已满足：nr_hugepages = $cur_hp >= $HUGEPAGES，跳过分配"
    ok "直通准备完成，可以启动虚拟机了"
    exit 0
fi

hpsize_kb=$(awk '/^Hugepagesize:/ {print $2}' /proc/meminfo)
: "${hpsize_kb:=2048}"
need_mb=$(( HUGEPAGES * hpsize_kb / 1024 ))
avail_mb=$(awk '/^MemAvailable:/ {print int($2/1024)}' /proc/meminfo)

log "大页：$HUGEPAGES x ${hpsize_kb}kB ≈ ${need_mb}MB（可用 ${avail_mb}MB）"
(( need_mb <= avail_mb )) || warn "可用内存小于需求，分配可能不足"

log "sync + drop_caches + compact_memory（大内存机器可能耗时）"
sync
echo 3 > /proc/sys/vm/drop_caches    || warn "drop_caches 失败（可忽略）"
echo 1 > /proc/sys/vm/compact_memory || warn "compact_memory 失败（可忽略）"
sysctl -w vm.nr_hugepages="$HUGEPAGES" >/dev/null || warn "sysctl 设置返回非零"

hp=$(cat /proc/sys/vm/nr_hugepages 2>/dev/null || echo 0)
if (( hp >= HUGEPAGES )); then
    ok "nr_hugepages = $hp"
else
    warn "nr_hugepages = $hp < $HUGEPAGES（碎片过多）"
    warn "可尝试：echo 1 > /proc/sys/vm/compact_memory && sysctl -w vm.nr_hugepages=$HUGEPAGES"
    warn "或在 GRUB 内核命令行加入 hugepages=$HUGEPAGES 预分配"
fi

ok "直通准备完成，可以启动虚拟机了"

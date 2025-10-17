if status is-interactive
    # ========== 基础设置 ==========
    set -g fish_greeting ''
    # ========== Vi 模式 ==========
    fish_vi_key_bindings
    set -g fish_cursor_insert line
    set -gx EDITOR nvim
    set -gx VISUAL nvim
    bind --mode insert \ce fish_edit_commandline
    bind --mode default v fish_edit_commandline
    # ========== 路径管理 ==========
    source "$HOME/.cargo/env.fish"
    # 设置 Android SDK 根目录
    set -gx ANDROID_SDK_ROOT ~/Android/Sdk
    # 将最新版 cmdline-tools 加入 PATH（优先使用 latest 目录下的工具）
    set -gx PATH $ANDROID_SDK_ROOT/cmdline-tools/latest/bin $PATH
    # 添加 platform-tools（含 adb 等工具）
    set -gx PATH $ANDROID_SDK_ROOT/platform-tools $PATH
    # 添加 build-tools（含编译工具）
    set -gx PATH $ANDROID_SDK_ROOT/build-tools/35.0.0 $PATH
    # ========== Rust ==========
    set -x RUSTC_WRAPPER sccache
    set -x SCCACHE_DIR "$HOME/.cache/sccache"
    set -x SCCACHE_CACHE_SIZE 20G
    set -x SCCACHE_COMPRESSION zstd
    set -x SCCACHE_MAX_STORES 100
    set -x SCCACHE_NO_DISTRIBUTED 1
    set -x SCCACHE_IDLE_TIMEOUT 3600
    # ========== 别名管理 ==========
    alias e="eza --icons --group-directories-first --git"
    alias et="e --tree --level=2 --git-ignore"
    alias eal="e -a -l"
    alias v="nvim"
    alias s="source"
    alias sv="sudo nvim"
    alias vf="v ~/.config/fish/config.fish"
    alias vh="v ~/.config/hypr/hyprland.conf"
    alias sf="s ~/.config/fish/config.fish"
    alias MG="sudo mount /dev/nvme0n1p3 ~/dev/local/"
    alias cls="clear"
    alias mkd="mkdir -p"
    alias fdf="fd -H -t f"
    alias fdd="fd -H -t d"
    alias GP="git push"
    alias GU="git pull"
    alias GS="git status"
    alias GA="git add ."
    alias GC="git commit"
    alias show="fastfetch"
    # ========== 工具管理 ==========
    starship init fish | source
    fzf --fish | source
    set -gx _ZO_MAXAGE 5000
    zoxide init fish | source

end

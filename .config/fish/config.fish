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

    set -gx JAVA_HOME /usr/lib/jvm/java-17-openjdk
    set -gx PATH $JAVA_HOME/bin $PATH

    set -gx WASM_OPT /usr/bin/wasm-opt

    # 配置 CUDA 的可执行文件路径
    set -x PATH /opt/cuda/bin $PATH
    # 配置 CUDA 的共享库路径（无则创建）
    set -x LD_LIBRARY_PATH /opt/cuda/lib64

    # ========== Rust ==========
    set -x RUSTC_WRAPPER sccache
    set -x SCCACHE_DIR "$HOME/.cache/sccache"
    set -x SCCACHE_CACHE_SIZE 20G
    set -x SCCACHE_COMPRESSION zstd
    set -x SCCACHE_MAX_STORES 100
    set -x SCCACHE_NO_DISTRIBUTED 1
    set -x SCCACHE_IDLE_TIMEOUT 3600
    set -x RUSTUP_UPDATE_ROOT https://mirrors.tuna.tsinghua.edu.cn/rustup/rustup
    set -x RUSTUP_DIST_SERVER https://mirrors.tuna.tsinghua.edu.cn/rustup
    # ========== 别名管理 ==========
    alias j="bash ~/bash/j.bash"
    alias o="bash ~/bash/o.bash"
    alias e="eza --icons --group-directories-first --git"
    alias et="e --git-ignore -T -L" # 后面跟数字代表显示层级
    alias eal="e -a -l"
    alias v="nvim"
    alias s="source"
    alias sv="sudo nvim"
    alias vf="v ~/.config/fish/config.fish"
    alias sf="s ~/.config/fish/config.fish"
    alias cls="clear"
    alias mkd="mkdir -p"
    alias backup-dir-contents="~/bash/backup-dir-contents.bash"
    # 替换 rm 为回收站删除，避免误删
    alias rm='trash-put'
    # 恢复回收站文件（rm restore）
    alias rmre='trash-restore'
    # 从回收站彻底删除某文件（rm remove）
    alias rmrm='trash-rm'
    # 查看回收站文件列表（rm list）
    alias rmlist='trash-list'
    # 清空回收站（rm all，谨慎使用）
    alias rmall='trash-empty'
    alias fdf="fd -H -t f"
    alias fdd="fd -H -t d"
    alias GS="git status"
    alias GA="git add ."
    alias GC="git commit"
    alias GR="git restore"
    alias GP="git push"
    alias show="fastfetch"
    # ========== 工具管理 ==========
    starship init fish | source
    fzf --fish | source
    set -gx _ZO_MAXAGE 5000
    zoxide init fish | source

    if status is-login
        and test -z "$WAYLAND_DISPLAY"
        and test "$XDG_VTNR" = 1
        and test -z "$NIRI_STARTED"
        set -x NIRI_STARTED 1
        exec niri
    end
end

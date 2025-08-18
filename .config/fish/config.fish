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
    set -q CARGO_HOME || set CARGO_HOME $HOME/.cargo
    fish_add_path $CARGO_HOME/bin
    # >>> conda initialize >>>
    if test -f ~/miniconda3/bin/conda
        eval ~/miniconda3/bin/conda shell.fish hook $argv | source
    else
        if test -f ~/miniconda3/etc/fish/conf.d/conda.fish
            . ~/miniconda3/etc/fish/conf.d/conda.fish
        else
            set -x PATH ~/miniconda3/bin $PATH
        end
    end
    # <<< conda initialize <<<
    # ========== Rust ==========
    # set -x RUSTFLAGS "-C linker=lld"
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
    alias MG="sudo mount /dev/nvme0n1p3 ~/dev/git"
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

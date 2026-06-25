if status is-interactive
    # ========== 基础设置 ==========
    set -g fish_greeting ''

    # ========== Vi 模式 ==========
    fish_vi_key_bindings
    set -g fish_cursor_insert line
    bind --mode insert \ce fish_edit_commandline
    bind --mode default v fish_edit_commandline

    #========== 路径管理 ==========
    # Rust
    source "$HOME/.cargo/env.fish"
    # set -gx WASM_OPT /usr/bin/wasm-opt
    set -x PYENV_ROOT "$HOME/.pyenv"
    set -x PATH "$PYENV_ROOT/bin" $PATH
    status --is-interactive; and source (pyenv init - | psub)
    status --is-interactive; and source (pyenv virtualenv-init - | psub)

    # ========== 别名管理 ==========
    alias cp="rsync -a"
    alias y="yazi"
    alias lg="lazygit"
    alias e="eza --icons --group-directories-first --git"
    alias et="eza --git-ignore -T -L" # 后面跟数字代表显示层级
    alias el="eza -l"
    alias eal="eza -a -l"
    alias v="nvim"
    alias s="source"
    alias sv="sudo nvim"
    alias vb="v ~/.bashrc"
    alias ve="v ~/.config/niri/wudixianxin/environment.kdl"
    alias vf="v ~/.config/fish/config.fish"
    alias sf="s ~/.config/fish/config.fish"
    alias cls="clear"
    alias mkd="mkdir -p"
    alias backup-dir-contents="~/bash/backup-dir-contents.bash"

    # 回收站操作（基于 trash-cli）
    alias rm='trash-put' # 替换 rm 为回收站删除
    alias rmre='trash-restore' # 恢复回收站文件
    alias rmrm='trash-rm' # 从回收站彻底删除某文件
    alias rmlist='trash-list' # 查看回收站文件列表
    alias rmall='trash-empty' # 清空回收站

    # 文件查找
    alias fdf="fd -E /.snapshots -H -t f"
    alias fdd="fd -E /.snapshots -H -t d"

    # Git 快捷命令
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

end

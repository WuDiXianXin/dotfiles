# ============================================================================
# Fish Shell 配置
# ============================================================================

if status is-interactive

    # ========== 基础设置 ==========
    # 关闭默认欢迎语（如需开机展示系统信息，可启用下方 fastfetch 函数）
    set -g fish_greeting ''
    # function fish_greeting
    #     fastfetch
    # end

    # 美化 man 手册：col 处理退格，bat 负责语法高亮
    set -x MANROFFOPT '-c'
    set -x MANPAGER 'sh -c "col -bx | bat -l man -p"'

    # ========== Vi 模式 ==========
    # 使用 Vi 键位，并将插入模式光标设为竖线
    fish_vi_key_bindings
    set -g fish_cursor_insert line
    # Ctrl-E：在插入/普通模式下都调用外部编辑器编辑当前命令行
    bind --mode insert \ce edit_command_buffer
    bind --mode default \ce edit_command_buffer

    # ========== 路径管理 ==========
    # 把用户级可执行目录加入 PATH
    fish_add_path ~/.local/bin ~/.cargo/bin

    # pyenv 相关（如使用请取消注释）
    # set -gx WASM_OPT /usr/bin/wasm-opt
    # set -x PYENV_ROOT "$HOME/.pyenv"
    # set -x PATH "$PYENV_ROOT/bin" $PATH
    # status --is-interactive; and source (pyenv init - | psub)
    # status --is-interactive; and source (pyenv virtualenv-init - | psub)

    # ========== 工具初始化 ==========
    starship init fish | source     # 提示符主题
    fzf --fish | source             # 模糊查找键绑定
    zoxide init fish | source       # 智能 cd（z 命令）
    set -gx _ZO_MAXAGE 5000         # zoxide 目录条目最大保留数

    # ========== 自定义函数 ==========
    # 显示带时间戳的历史记录
    function history
        builtin history --show-time='%F %T ' $argv
    end

    # 为指定文件创建 .bak 备份
    function backup --argument filename
        cp $filename $filename.bak
    end

    # 智能复制：当源是目录时自动加 -r 递归复制
    function copy
        set count (count $argv)
        if test "$count" = 2; and test -d "$argv[1]"
            command cp -r $argv[1] $argv[2]
        else
            command cp $argv
        end
    end

    # ========== 别名 ==========
    # --- 编辑器 ---
    alias v='nvim'
    alias sv='sudo -e'

    # --- 文件浏览 (eza) ---
    alias l.='eza -a | rg "^\."'              # 仅列出隐藏文件
    alias l='eza -s type --color=auto --icons=auto'
    alias la='eza -a -s type --color=auto --icons=auto'
    alias ll='eza -lg -s type --color=auto --icons=auto --time-style="+%Y-%m-%d %H:%M:%S"'
    alias lla='eza -alg -s type --color=auto --icons=auto --time-style="+%Y-%m-%d %H:%M:%S"'
    alias lt='eza -s type -T -L'              # 树状结构
    alias lta='eza -a -s type -T -L'

    # --- 常用工具 ---
    alias cls='clear'
    alias mkd='mkdir -p'
    alias p='bat -pp'
    alias y='yazi'
    alias lg='lazygit'
    alias show='fastfetch'

    # --- 本配置快捷编辑 ---
    alias vf='v ~/.config/fish/config.fish'
    alias sf='source ~/.config/fish/config.fish'

    # --- 复制/同步 ---
    alias cpr='rsync -a --info=progress2'

    # --- chezmoi 与自定义脚本 ---
    alias b='chezmoi'
    alias B='~/bash/backup-dir-contents.bash'
    alias enable-passthrough='sudo ~/bash/enable-passthrough.bash'
    alias disable-passthrough='sudo ~/bash/disable-passthrough.bash'

    # --- 回收站操作 (trash-cli) ---
    alias rm='trash-put'         # 删除到回收站
    alias rmre='trash-restore'   # 从回收站恢复
    alias rmrm='trash-rm'        # 从回收站彻底删除指定文件
    alias rmlist='trash-list'    # 查看回收站列表
    alias rmall='trash-empty'    # 清空回收站

    # --- 文件查找 (fd) ---
    alias fdf='fd -E /.snapshots -H -t f'
    alias fdd='fd -E /.snapshots -H -t d'

    # --- Git ---
    alias GS='git status'
    alias Gs='git switch'
    alias GD='git diff'
    alias GA='git add'
    alias GC='git commit'
    alias GR='git restore'
    alias GP='git push'

    # --- 目录跳转 ---
    alias ..='cd ..'
    alias ...='cd ../..'
    alias ....='cd ../../..'
    alias .....='cd ../../../..'
    alias ......='cd ../../../../..'

    # --- 系统维护 (CachyOS) ---
    alias fixpacman="sudo rm /var/lib/pacman/db.lck"    # 解除 pacman 锁
    alias update='sudo pacman -Syu'                     # 更新系统软件包
    alias update-aur='paru -Sua'                        # 更新 aur 软件包
    alias mirror="sudo cachyos-rate-mirrors"            # 仅刷新镜像
    alias cleanup='sudo pacman -Rns (pacman -Qtdq)'     # 清理孤立包
    alias jctl="journalctl -p 3 -xb"                    # 查看本次启动的错误日志

    # --- 归档 ---
    alias tarnow='tar -acf'
    alias untar='tar -xf'

end

# ~/.bashrc

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# ========== 环境 ==========
. "$HOME/.cargo/env"
source ~/bash/j.bash
source ~/bash/o.bash
source ~/bash/proxy.bash
. /usr/share/bash-completion/bash_completion

# ========== 别名管理 ==========
alias cp="rsync -a"
alias e="eza --icons --group-directories-first --git"
alias et="eza --git-ignore -T -L" # 后面跟数字代表显示层级
alias eal="eza -a -l"
alias v="nvim"
alias s="source"
alias sv="sudo nvim"
alias cls="clear"
alias mkd="mkdir -p"
alias backup-dir-contents="~/bash/backup-dir-contents.bash"

# 回收站操作（基于 trash-cli）
alias rm='trash-put'       # 替换 rm 为回收站删除
alias rmre='trash-restore' # 恢复回收站文件
alias rmrm='trash-rm'      # 从回收站彻底删除某文件
alias rmlist='trash-list'  # 查看回收站文件列表
alias rmall='trash-empty'  # 清空回收站

# 文件查找
alias fdf="fd -H -t f"
alias fdd="fd -H -t d"

# Git 快捷命令
alias GS="git status"
alias GA="git add ."
alias GC="git commit"
alias GR="git restore"
alias GP="git push"

alias show="fastfetch"

# ========== 工具初始化 ==========
eval "$(starship init bash)"
eval "$(fzf --bash)"
export _ZO_MAXAGE=5000
eval "$(zoxide init bash)"

#!/usr/bin/env bash
# ========== 基础设置 ==========
[[ $- != *i* ]] && return
BASH_LOAD_START=$(date +%s%3N)
# ========== 历史记录增强 ==========
HISTFILE="$HOME/.bash_history"
HISTSIZE=100000
HISTFILESIZE=200000
HISTCONTROL=ignoredups:ignorespace
shopt -s histappend cmdhist lithist
PROMPT_COMMAND="history -a;$PROMPT_COMMAND"
# ========== 路径管理 ==========
[[ -f "$HOME/.cargo/env" ]] && . "$HOME/.cargo/env"
# >>> conda initialize >>>
__conda_setup="$('~/miniconda3/bin/conda' shell.bash hook 2>/dev/null)"
if [ $? -eq 0 ]; then
  eval "$__conda_setup"
elif [ -f "~/miniconda3/etc/profile.d/conda.sh" ]; then
  . "~/miniconda3/etc/profile.d/conda.sh"
else
  export PATH="~/miniconda3/bin:$PATH"
fi
unset __conda_setup
# <<< conda initialize <<<
# ========== 工具集成 ==========
# source /usr/share/bash-completion/bash_completion
# source ~/make/ble.sh/out/ble.sh
# source /usr/share/fzf/{key-bindings,completion}.bash
# eval "$(direnv hook bash)"
eval "$(starship init bash)"
source "$HOME/bash/j.bash"
source "$HOME/bash/o.bash"
export XMODIFIERS=@im=fcitx
export QT_IM_MODULE=fcitx
export GTK_IM_MODULE=fcitx
export _ZO_MAXAGE=5000
eval "$(zoxide init bash)"
# ========== Vi 模式与输入优化 ==========
set -o vi
# ========== 别名与函数 ==========
alias e='eza --icons --group-directories-first --git'
alias et='e --tree --level=2 --git-ignore'
alias eal='e -a -l'
alias v='nvim'
alias s='source'
alias cls='clear'
alias mkd='mkdir -p'
alias fdf='fd -H -t f'
alias fdd='fd -H -t d'
# ========== 性能监控 ==========
BASH_LOAD_END=$(date +%s%3N)
echo -e "\033[34m[bashrc]\033[0m 加载耗时: $((BASH_LOAD_END - BASH_LOAD_START))ms"

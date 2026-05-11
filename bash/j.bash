#!/bin/bash

j() {
  # 依赖检查
  for cmd in fd fzf eza; do
    if ! command -v "$cmd" &>/dev/null; then
      echo "Error: required command '$cmd' not found" >&2
      return 1
    fi
  done

  local search_pattern="${1:-.}"
  local search_path="${2:-$HOME}"

  if [[ ! -d "$search_path" ]]; then
    echo "Error: '$search_path' is not a valid directory" >&2
    return 1
  fi

  # 构建 fd 选项，只在忽略文件存在时添加
  local fd_opts=(--type d --hidden --color=never)
  local ignore_file="$HOME/bash/.fdignore-dirs"
  [[ -f "$ignore_file" ]] && fd_opts+=(--ignore-file "$ignore_file")
  # 如果 fd 版本支持，限制结果数量，防止超大数据集卡死 fzf
  if fd --help 2>&1 | grep -q -- '--max-results'; then
    fd_opts+=(--max-results 1000)
  fi

  local dir
  # 使用 --exit-0 确保 fzf 没有匹配时直接退出，不报错
  # 预览命令对目录显示树，对文件只显示基本信息，提升预览速度
  dir=$(
    fd "${fd_opts[@]}" "$search_pattern" "$search_path" 2>/dev/null |
      fzf --height 60% --reverse \
        --preview-window right:50%:wrap \
        --preview '
        if [[ -d {} ]]; then
          eza --color=always --icons --group-directories-first --git-ignore --tree --level=2 {}
        else
          eza --color=always --icons --group-directories-first --git-ignore -1 {}
        fi
      ' \
        --exit-0
  )

  if [[ -n "$dir" ]]; then
    # 如果选中的是文件，跳转到其父目录
    if [[ -f "$dir" ]]; then
      cd "$(dirname "$dir")" || return 1
    else
      cd "$dir" || return 1
    fi
    echo "📁 $(pwd)"
  else
    echo "󰅖 Cancelled" >&2
    return 1
  fi
}

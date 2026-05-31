#!/bin/bash

o() {
  # 依赖检查
  for cmd in fd fzf bat nvim; do
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

  # 构建 fd 选项，始终只搜索文件（含符号链接文件）
  local fd_opts=(--type f --hidden --color=never)
  local ignore_file="$HOME/bash/.fdignore-files"
  [[ -f "$ignore_file" ]] && fd_opts+=(--ignore-file "$ignore_file")

  # 限制结果数量，避免 fzf 因海量结果卡顿
  if fd --help 2>&1 | grep -q -- '--max-results'; then
    fd_opts+=(--max-results 1000)
  fi

  local file
  file=$(
    fd "${fd_opts[@]}" "$search_pattern" "$search_path" 2>/dev/null |
      fzf --height 60% --reverse \
        --preview-window right:50%:wrap \
        --preview 'bat --color=always --line-range :500 {}' \
        --exit-0
  )

  if [[ -n "$file" ]]; then
    nvim "$file" && echo "📝 $file" || return 1
  else
    echo "󰅖 Cancelled" >&2
    return 1
  fi
}

# j [搜索关键词] [起始目录]
# 无参数：搜索整个 $HOME 下的所有目录，在 fzf 中选一个，cd 过去。
# 一个参数：搜索名称匹配该关键词的目录（模糊匹配），默认从 $HOME 开始。
# 两个参数：第一个是关键词，第二个是指定搜索起始目录（可以写相对路径或绝对路径）。

function j --description "通过 fzf 快速跳转到目录"
    for cmd in fd fzf eza
        if not command -q $cmd
            echo "Error: required command '$cmd' not found" >&2
            return 1
        end
    end

    set -l pattern "."
    test (count $argv) -ge 1; and set pattern $argv[1]
    set -l search_path "$HOME"
    test (count $argv) -ge 2; and set search_path $argv[2]

    if test ! -d "$search_path"
        echo "Error: '$search_path' is not a valid directory" >&2
        return 1
    end

    set -l fd_opts --type d --hidden --color=never --absolute-path
    set -l ignore_file "$HOME/bash/.fdignore-dirs"
    test -f "$ignore_file"; and set -a fd_opts --ignore-file "$ignore_file"
    if fd --help 2>&1 | string match -q -- --max-results
        set -a fd_opts --max-results 1000
    end

    set -l dir (fd $fd_opts "$pattern" "$search_path" 2>/dev/null | \
        fzf --height 60% --reverse --exit-0)

    if test -n "$dir"
        if test -f "$dir"
            cd (dirname "$dir") || return 1
        else
            cd "$dir" || return 1
        end
        echo "📁 $PWD"
    else
        echo "󰅖 Cancelled" >&2
        return 1
    end
end

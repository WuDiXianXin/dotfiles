# o [搜索关键词] [起始目录]
# 无参数：搜索 $HOME 下所有文件，选一个用 nvim 打开。
# 一个参数：按关键词过滤文件。
# 两个参数：关键词 + 起始目录。

function o --description "通过 fzf 选择文件并用 neovim 打开"
    for cmd in fd fzf bat nvim
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

    set -l fd_opts --type f --hidden --color=never --absolute-path
    set -l ignore_file "$HOME/bash/.fdignore-files"
    test -f "$ignore_file"; and set -a fd_opts --ignore-file "$ignore_file"
    if fd --help 2>&1 | string match -q -- --max-results
        set -a fd_opts --max-results 1000
    end

    set -l file (fd $fd_opts "$pattern" "$search_path" 2>/dev/null | \
        fzf --height 60% --reverse --exit-0)

    if test -n "$file"
        nvim "$file" && echo "📝 $file" || return 1
    else
        echo "󰅖 Cancelled" >&2
        return 1
    end
end

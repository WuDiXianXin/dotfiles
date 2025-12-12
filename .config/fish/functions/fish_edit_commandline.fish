function fish_edit_commandline
    # 创建临时文件并检查是否成功
    set -l tmpfile (mktemp 2>/dev/null)
    if not set -q tmpfile[1] || not test -f $tmpfile
        echo "Failed to create temp file" >&2 # 错误输出重定向到stderr
        return 1
    end

    # 将当前命令行内容写入临时文件
    if not commandline >$tmpfile
        echo "Failed to save commandline" >&2
        command rm -f $tmpfile 2>/dev/null # 屏蔽删除失败的报错
        return 1
    end

    # 调用编辑器（支持环境变量回退）
    set -l editor (command -v $EDITOR || command -v nano || command -v vi)
    if not $editor $tmpfile
        echo "Editor execution failed" >&2
        command rm -f $tmpfile 2>/dev/null
        return 1
    end

    # 加载编辑后的内容并清理
    commandline -r (cat $tmpfile | string collect)
    commandline -f repaint
    command rm -f $tmpfile 2>/dev/null # 最终清理临时文件（原生rm）
end

-- 文件浏览器
return {
    {
        'nvim-mini/mini.files',
        lazy = false,
        config = function()
            require('mini.files').setup({
                windows = {
                    preview = true,
                    width_focus = 25,
                    width_preview = 80,
                },
            })

            local nmap = require('utils.keymap').nmap
            nmap('<leader>e', '<cmd>lua MiniFiles.open()<CR>', 'mini.files: 打开文件管理器')

            nmap('<leader>E', function()
                -- 1. 获取当前 Buffer 的完整路径
                local current_buf_path = vim.api.nvim_buf_get_name(0)

                -- 2. 如果当前 Buffer 没有关联文件（例如是一个新 Buffer），则给出提示并退出
                if current_buf_path == '' then
                    vim.notify('当前 Buffer 没有关联文件', vim.log.levels.WARN)
                    return
                end

                -- 3. 提取该文件所在的目录路径
                local target_dir = vim.fs.dirname(current_buf_path)

                -- 4. 将 Neovim 的工作目录 (CWD) 切换到目标目录
                vim.fn.chdir(target_dir)

                -- 5. 调用 mini.files，以当前 Buffer 的路径为锚点打开
                require('mini.files').open(current_buf_path)
            end, 'mini.files: 打开当前文件目录并切换CWD')
        end,
    },
}

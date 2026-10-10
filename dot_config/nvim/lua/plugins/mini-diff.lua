-- git 侧边栏修改提示
return {
    {
        'nvim-mini/mini.diff',
        event = 'BufReadPost',
        config = function()
            local colors = require('tokyonight.colors').setup()

            vim.api.nvim_set_hl(0, 'MiniDiffSignAdd', { fg = colors.git.add })
            vim.api.nvim_set_hl(0, 'MiniDiffSignChange', { fg = colors.git.change })
            vim.api.nvim_set_hl(0, 'MiniDiffSignDelete', { fg = colors.git.delete })

            vim.api.nvim_set_hl(0, 'MiniDiffOverAdd', { fg = colors.git.add, bg = colors.git.add })
            vim.api.nvim_set_hl(0, 'MiniDiffOverChange', { fg = colors.git.change, bg = colors.git.change })
            vim.api.nvim_set_hl(0, 'MiniDiffOverDelete', { fg = colors.git.delete, bg = colors.git.delete })

            require('mini.diff').setup({
                view = {
                    style = 'sign',
                    signs = {
                        add = '┃',
                        change = '┃',
                        delete = '▁',
                    },
                },

                delay = {
                    text_change = 200,
                },
                mappings = {
                    -- 在可视模式或操作符模式下应用（暂存）指定的 hunk
                    apply = '<leader>ga',

                    -- 在可视模式或操作符模式下重置（撤销修改）指定的 hunk
                    reset = '<leader>gr',

                    -- hunk 范围的文本对象，用于操作符（如 d, y, c 等）
                    -- 如果该映射与 apply / reset 不同，也可在可视模式下使用
                    textobject = 'gh',

                    -- 跳转到第一个 hunk
                    goto_first = '[H',
                    -- 跳转到上一个 hunk
                    goto_prev = '[h',
                    -- 跳转到下一个 hunk
                    goto_next = ']h',
                    -- 跳转到最后一个 hunk
                    goto_last = ']H',
                },

                options = {
                    max_size = 50000,

                    -- 差异算法，可选：'myers'、'minimal'、'patience'、'histogram'
                    algorithm = 'histogram',

                    -- 是否使用“缩进启发式”，使差异块更贴近缩进结构
                    indent_heuristic = true,

                    -- 二次对齐的行数（行匹配范围），用于将差异块内的行更精细地配对
                    linematch = 150,

                    -- 在跳转差异块（hunk）时是否环绕（从最后一个跳转到第一个，反之亦然）
                    wrap_goto = false,
                },
            })

            require('which-key').add({
                { '<leader>g', group = 'Git/Diff' },
            })
        end,
    },
}

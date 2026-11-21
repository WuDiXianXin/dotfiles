return {
    {
        'nvim-treesitter/nvim-treesitter',
        branch = 'main',
        build = ':TSUpdate',
        config = function()
            local parser_list = {
                -- 核心语言
                'rust',
                'c',
                'cpp',
                'lua',
                'luadoc',
                'vim',
                'vimdoc',
                'query',

                'python',
                'java',
                'go',

                'javascript',
                'html',
                'css',

                'typescript',
                'tsx',

                'gdscript',

                -- 配置 / 数据
                'toml',
                'yaml',
                'json',
                'ini',
                'kdl',
                'xml',

                'ron',

                -- 文档 / 标记
                'markdown',
                'markdown_inline',

                -- Shell
                'bash',
                'fish',

                -- Git / Diff
                'git_config',
                'git_rebase',
                'gitcommit',
                'gitignore',
                'gitattributes',

                'diff',

                -- 其他
                'regex',

                'dockerfile',
                'make',
                'cmake',
            }

            -- 异步安装 parser
            require('nvim-treesitter').install(parser_list)

            -- 自动对支持的 filetype 开启 treesitter 功能
            vim.api.nvim_create_autocmd('FileType', {
                pattern = parser_list,
                callback = function(args)
                    local buf = args.buf

                    -- 开启内置 treesitter 高亮
                    pcall(vim.treesitter.start, buf)
                end,
            })
        end,
    },
    {
        'nvim-treesitter/nvim-treesitter-textobjects',
        branch = 'main',
        -- 依赖 nvim-treesitter 主插件（textobjects 需要 treesitter 解析器支持）
        dependencies = {
            { 'nvim-treesitter/nvim-treesitter', branch = 'main' },
        },
        init = function()
            -- 建议关闭内置 ftplugin 的映射，避免冲突
            vim.g.no_plugin_maps = true
        end,
        config = function()
            -- ================================================================
            -- 基础设置
            -- ================================================================
            require('nvim-treesitter-textobjects').setup({
                select = {
                    -- 向前预查：光标位于对象前时也能选中
                    lookahead = true,
                    -- 指定各类文本对象被选中时的模式
                    selection_modes = {
                        ['@parameter.outer'] = 'v', -- 字符模式（charwise）
                        ['@function.outer'] = 'V', -- 行模式（linewise）
                        ['@class.outer'] = 'V', -- 行模式（linewise）
                    },
                    -- 选中时是否包含周围空白
                    include_surrounding_whitespace = false,
                },
                move = {
                    -- 跳转时记录到 jumplist，方便使用 Ctrl+O / Ctrl+I 回跳
                    set_jumps = true,
                },
            })

            ------------------------------------------------------------------
            -- 选择文本对象（Select textobjects）
            -- 在可视模式（x）和操作符待定模式（o）下生效
            ------------------------------------------------------------------
            local select = require('nvim-treesitter-textobjects.select')
            -- 通用映射辅助函数：将按键绑定到“选择指定文本对象”的动作
            local function map_select(mode, lhs, query, desc)
                vim.keymap.set(mode, lhs, function()
                    select.select_textobject(query, 'textobjects')
                end, { silent = true, desc = desc })
            end

            -- 函数（function）
            map_select({ 'x', 'o' }, 'af', '@function.outer', '选中整个函数（含函数体）')
            map_select({ 'x', 'o' }, 'if', '@function.inner', '选中函数内部（不含函数签名）')
            -- 类 / 结构体（class / struct）
            map_select({ 'x', 'o' }, 'ac', '@class.outer', '选中整个类')
            map_select({ 'x', 'o' }, 'ic', '@class.inner', '选中类内部')
            -- 参数 / 实参（parameter / argument）
            map_select({ 'x', 'o' }, 'aa', '@parameter.outer', '选中一个参数')
            map_select({ 'x', 'o' }, 'ia', '@parameter.inner', '选中参数内部')
            -- 条件语句（conditional：if/else/switch 等）
            map_select({ 'x', 'o' }, 'ai', '@conditional.outer', '选中整个条件块')
            map_select({ 'x', 'o' }, 'ii', '@conditional.inner', '选中条件块内部')
            -- 循环（loop：for/while 等）
            map_select({ 'x', 'o' }, 'al', '@loop.outer', '选中整个循环块')
            map_select({ 'x', 'o' }, 'il', '@loop.inner', '选中循环块内部')
            -- 代码块（block：{} 包裹的块）
            map_select({ 'x', 'o' }, 'ab', '@block.outer', '选中整个代码块')
            map_select({ 'x', 'o' }, 'ib', '@block.inner', '选中代码块内部')
            -- 注释（comment）
            map_select({ 'x', 'o' }, 'a/', '@comment.outer', '选中整条注释')
            map_select({ 'x', 'o' }, 'i/', '@comment.inner', '选中注释内容')
            -- 赋值语句（assignment）
            map_select({ 'x', 'o' }, 'a=', '@assignment.outer', '选中整个赋值语句')
            map_select({ 'x', 'o' }, 'i=', '@assignment.inner', '选中赋值语句内部')
            map_select({ 'x', 'o' }, 'l=', '@assignment.lhs', '选中赋值左侧（左值）')
            map_select({ 'x', 'o' }, 'r=', '@assignment.rhs', '选中赋值右侧（右值）')
            -- 函数调用（call）
            map_select({ 'x', 'o' }, 'am', '@call.outer', '选中整个函数调用')
            map_select({ 'x', 'o' }, 'im', '@call.inner', '选中调用内部（实参列表）')

            ------------------------------------------------------------------
            -- 移动（Move）
            -- 在普通/可视/操作符待定模式下按方向跳转到文本对象
            ------------------------------------------------------------------
            local move = require('nvim-treesitter-textobjects.move')

            -- 通用映射辅助函数：direction 指定跳转方向
            local function map_move(modes, lhs, query, direction, desc)
                vim.keymap.set(modes, lhs, function()
                    if direction == 'next_start' then
                        move.goto_next_start(query, 'textobjects') -- 下一个对象的起始处
                    elseif direction == 'next_end' then
                        move.goto_next_end(query, 'textobjects') -- 下一个对象的结束处
                    elseif direction == 'prev_start' then
                        move.goto_previous_start(query, 'textobjects') -- 上一个对象的起始处
                    elseif direction == 'prev_end' then
                        move.goto_previous_end(query, 'textobjects') -- 上一个对象的结束处
                    end
                end, { silent = true, desc = desc })
            end

            -- 函数（function）跳转
            map_move({ 'n', 'x', 'o' }, ']f', '@function.outer', 'next_start', '跳到下一个函数（开始）')
            map_move({ 'n', 'x', 'o' }, ']F', '@function.outer', 'next_end', '跳到下一个函数（结束）')
            map_move({ 'n', 'x', 'o' }, '[f', '@function.outer', 'prev_start', '跳到上一个函数（开始）')
            map_move({ 'n', 'x', 'o' }, '[F', '@function.outer', 'prev_end', '跳到上一个函数（结束）')
            -- 类 / 结构体（class / struct）跳转
            map_move({ 'n', 'x', 'o' }, ']c', '@class.outer', 'next_start', '跳到下一个类（开始）')
            map_move({ 'n', 'x', 'o' }, ']C', '@class.outer', 'next_end', '跳到下一个类（结束）')
            map_move({ 'n', 'x', 'o' }, '[c', '@class.outer', 'prev_start', '跳到上一个类（开始）')
            map_move({ 'n', 'x', 'o' }, '[C', '@class.outer', 'prev_end', '跳到上一个类（结束）')
            -- 参数 / 实参（parameter / argument）跳转
            map_move({ 'n', 'x', 'o' }, ']a', '@parameter.inner', 'next_start', '跳到下一个参数（开始）')
            map_move({ 'n', 'x', 'o' }, ']A', '@parameter.inner', 'next_end', '跳到下一个参数（结束）')
            map_move({ 'n', 'x', 'o' }, '[a', '@parameter.inner', 'prev_start', '跳到上一个参数（开始）')
            map_move({ 'n', 'x', 'o' }, '[A', '@parameter.inner', 'prev_end', '跳到上一个参数（结束）')
            -- 条件语句（conditional：if/else/switch 等）跳转
            map_move(
                { 'n', 'x', 'o' },
                ']i',
                '@conditional.outer',
                'next_start',
                '跳到下一个条件块（开始）'
            )
            map_move({ 'n', 'x', 'o' }, ']I', '@conditional.outer', 'next_end', '跳到下一个条件块（结束）')
            map_move(
                { 'n', 'x', 'o' },
                '[i',
                '@conditional.outer',
                'prev_start',
                '跳到上一个条件块（开始）'
            )
            map_move({ 'n', 'x', 'o' }, '[I', '@conditional.outer', 'prev_end', '跳到上一个条件块（结束）')
            -- 循环（loop：for/while 等）跳转
            map_move({ 'n', 'x', 'o' }, ']l', '@loop.outer', 'next_start', '跳到下一个循环块（开始）')
            map_move({ 'n', 'x', 'o' }, ']L', '@loop.outer', 'next_end', '跳到下一个循环块（结束）')
            map_move({ 'n', 'x', 'o' }, '[l', '@loop.outer', 'prev_start', '跳到上一个循环块（开始）')
            map_move({ 'n', 'x', 'o' }, '[L', '@loop.outer', 'prev_end', '跳到上一个循环块（结束）')

            ------------------------------------------------------------------
            -- 交换（Swap）
            -- 用于快速交换两个相邻参数的位置
            ------------------------------------------------------------------
            local swap = require('nvim-treesitter-textobjects.swap')

            vim.keymap.set('n', '<leader>a', function()
                swap.swap_next('@parameter.inner')
            end, { desc = '与下一个参数交换' })

            vim.keymap.set('n', '<leader>A', function()
                swap.swap_previous('@parameter.inner')
            end, { desc = '与上一个参数交换' })

            ------------------------------------------------------------------
            -- 可重复移动（Repeatable move）
            -- 用 ; 和 , 重复上一次文本对象移动
            ------------------------------------------------------------------
            -- local ts_repeat_move = require('nvim-treesitter-textobjects.repeatable_move')
            -- vim.keymap.set(
            --     { 'n', 'x', 'o' },
            --     ';',
            --     ts_repeat_move.repeat_last_move_next,
            --     { desc = '重复上次移动（正向）' }
            -- )
            -- vim.keymap.set(
            --     { 'n', 'x', 'o' },
            --     ',',
            --     ts_repeat_move.repeat_last_move_previous,
            --     { desc = '重复上次移动（反向）' }
            -- )
        end,
    },
}

-- 快捷键提示
return {
    {
        'folke/which-key.nvim',
        event = 'VeryLazy',
        config = function()
            local wk = require('which-key')
            wk.setup({
                preset = 'modern',
                -- 启用官方内置插件
                plugins = {
                    marks = true, -- ' / ` 触发显示标记列表
                    registers = true, -- " / <C-r> 触发显示寄存器列表
                    spelling = false, -- 禁用拼写建议（非核心需求，减少干扰）
                    presets = {
                        operators = true, -- d/y/c 等操作符的原生绑定提示
                        motions = true, -- 原生移动快捷键提示
                        text_objects = true, -- 输入操作符（operator）之后,触发文本对象的提示
                        windows = true, -- <C-w> 窗口操作提示
                        nav = true, -- 方向键导航提示（h j k l 等）
                        g = true, -- g 前缀原生绑定提示（和你的 LSP g 前缀互补）
                        z = true, -- z 前缀折叠/拼写提示
                    },
                },
                -- 窗口样式
                win = {
                    border = 'rounded', -- 和 LazyVim 诊断窗口/终端风格一致
                    no_overlap = true, -- 避免弹窗覆盖光标
                    padding = { 1, 2 }, -- 官方默认内边距，视觉更舒适 [top/bottom, right/left]
                    title = true,
                    title_pos = 'center',
                    wo = { winblend = 10 }, -- 轻微透明，更协调 tokyonight
                },
                layout = {
                    height = { min = 4, max = 30 },
                    width = { min = 20, max = 40 },
                    spacing = 4, -- 组间距更宽松，阅读更舒适
                    align = 'center',
                },
                icons = {
                    breadcrumb = '»',
                    separator = '➜',
                    group = ' ', -- 用折叠图标表示组，更直观（需要 Nerd Font）
                    ellipsis = '…',
                    mappings = true,
                    rules = {}, -- 可自定义图标规则（目前无需）
                },
                show_help = false, -- 默认帮助提示
                show_keys = true, -- 显示当前按下的键

                debug = false,
            })

            -- 基础全局分组
            wk.add({
                { '<leader>b', group = '缓冲区' },
                { '<leader>t', group = '标签页' },
                { '<leader>w', group = '窗口' },
                { '<leader>g', group = 'Git/Diff' },
                { '<leader>l', group = 'Lazy/LSP' },
                { 'g', group = '跳转/窗口' },
            })

            -- 全局快捷键查看（? 键）
            local nmap = require('utils.keymap').nmap
            nmap('?', function()
                wk.show({ global = true })
            end, '查看所有快捷键 (WhichKey)')
        end,
    },
}

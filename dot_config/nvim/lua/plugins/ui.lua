return {
    {
        -- 图标
        'nvim-mini/mini.icons',
        priority = 1000,
        config = function()
            local mini_icons = require('mini.icons')
            mini_icons.setup({
                style = 'glyph',
                file = {
                    README = { glyph = '󰆈', hl = 'MiniIconsYellow' },
                    ['README.md'] = { glyph = '󰆈', hl = 'MiniIconsYellow' },
                },
                filetype = {
                    bash = { glyph = '󱆃', hl = 'MiniIconsGreen' },
                    sh = { glyph = '󱆃', hl = 'MiniIconsGrey' },
                    toml = { glyph = '󱄽', hl = 'MiniIconsOrange' },
                },
            })
            mini_icons.mock_nvim_web_devicons()
        end,
    },
    {
        -- LSP 加载状态通知
        'j-hui/fidget.nvim',
        event = 'LspAttach',
        opts = {},
    },
    {
        -- git 侧边栏修改提示
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
    {
        -- 文件浏览器
        'nvim-mini/mini.files',
        event = 'UIEnter',
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
    {
        -- 选择器 (picker)
        'nvim-mini/mini.pick',
        event = 'UIEnter',
        -- keys = {
        --     { '<leader>f', mode = 'n' },
        -- },
        config = function()
            require('mini.pick').setup()
            local nmap = require('utils.keymap').nmap
            nmap('<leader>ff', '<cmd>Pick files<CR>', '查找文件')
            nmap('<leader>fb', '<cmd>Pick buffers<CR>', '查找缓冲区')
            nmap('<leader>fg', '<cmd>Pick grep_live<CR>', '实时文本搜索')
            nmap('<leader>fG', '<cmd>Pick grep<CR>', '静态文本搜索')
            nmap('<leader>fr', '<cmd>Pick resume<CR>', '恢复上次查找')
            nmap('<leader>fh', '<cmd>Pick help<CR>', '搜索帮助文档')

            require('which-key').add({
                { '<leader>f', group = '查找' },
            })
        end,
    },
    {
        -- 额外工具集
        'nvim-mini/mini.extra',
        event = 'VeryLazy',
        config = function()
            require('mini.extra').setup()
        end,
    },
    {
        -- 快捷键提示
        'folke/which-key.nvim',
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
    {
        'nvim-lualine/lualine.nvim',
        event = 'UIEnter',
        config = function()
            local custom_theme = require('lualine.themes.tokyonight')
            local active_color = '#4fd6be'
            local inactive_color = '#c3e88d'

            custom_theme.normal.a.fg = active_color
            custom_theme.normal.a.bg = ''
            custom_theme.normal.b.fg = active_color
            custom_theme.normal.b.bg = ''
            custom_theme.normal.c.fg = active_color
            custom_theme.normal.c.bg = ''

            custom_theme.inactive.a.fg = inactive_color
            custom_theme.inactive.a.bg = ''
            custom_theme.inactive.b.fg = inactive_color
            custom_theme.inactive.b.bg = ''
            custom_theme.inactive.c.fg = inactive_color
            custom_theme.inactive.c.bg = ''

            require('lualine').setup({
                options = {
                    theme = custom_theme,
                    globalstatus = false, -- 设为 true 则全窗口共用一个 statusline
                    component_separators = { left = '', right = '' },
                    section_separators = { left = '', right = '' },
                },

                -- ==================== Section ====================

                sections = {
                    lualine_b = {
                        { 'branch', icon = '' },
                        { 'diff', symbols = { added = ' ', modified = ' ', removed = ' ' } },
                    },
                    lualine_c = {
                        'lsp_status',
                        {
                            'diagnostics',
                            sources = { 'nvim_diagnostic' },
                            symbols = { error = ' ', warn = ' ', info = ' ', hint = ' ' },
                        },
                    },
                    lualine_x = {
                        'encoding',
                        'fileformat',
                        'filetype',
                    },
                },

                inactive_sections = {},

                -- ==================== Winbar ====================

                -- winbar = {
                --     lualine_c = {
                --         {
                --             'filename',
                --             file_status = true, -- [关键设置] 启用文件状态显示
                --             path = 1, -- 可选: 0 = 仅文件名, 1 = 相对路径, 2 = 绝对路径
                --             symbols = { modified = '●', readonly = '', unnamed = 'No Name' },
                --         },
                --     },
                -- },
                --
                -- inactive_winbar = {
                --     lualine_c = {
                --         {
                --             'filename',
                --             file_status = true,
                --             path = 1,
                --             symbols = { modified = '●', readonly = '', unnamed = 'No Name' },
                --         },
                --     },
                -- },

                -- ==================== Tabline ====================

                tabline = {
                    lualine_a = {
                        {
                            'tabs',
                            symbols = { modified = ' ●' },
                        },
                    },

                    lualine_c = {
                        {
                            'buffers',
                        },
                    },
                },

                extensions = { 'quickfix', 'toggleterm', 'fugitive' },
            })
        end,
    },
}

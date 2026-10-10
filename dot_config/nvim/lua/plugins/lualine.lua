return {
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

                winbar = {
                    lualine_c = {
                        {
                            'filename',
                            file_status = true, -- [关键设置] 启用文件状态显示
                            path = 1, -- 可选: 0 = 仅文件名, 1 = 相对路径, 2 = 绝对路径
                            symbols = { modified = '●', readonly = '', unnamed = 'No Name' },
                        },
                    },
                },

                inactive_winbar = {
                    lualine_c = {
                        {
                            'filename',
                            file_status = true,
                            path = 1,
                            symbols = { modified = '●', readonly = '', unnamed = 'No Name' },
                        },
                    },
                },

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

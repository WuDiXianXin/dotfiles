vim.pack.add({
    {
        src = 'https://github.com/nvim-lualine/lualine.nvim',
        branch = 'master',
    },
})

local custom_theme = require('lualine.themes.auto')
-- custom_theme.normal.a.bg   = 'NONE'
-- custom_theme.normal.b.bg   = 'NONE'
custom_theme.normal.c.bg = 'NONE'

-- inactive（非活动窗口）
custom_theme.inactive.c.bg = 'NONE'
custom_theme.inactive.a.bg = 'NONE'
custom_theme.inactive.b.bg = 'NONE'

require('lualine').setup({
    options = {
        theme = custom_theme,
        -- section_separators = { left = '', right = '' },
        -- component_separators = { left = '', right = '' },
        globalstatus = false, -- 设为 true 则全窗口共用一个 statusline
    },

    -- ==================== Section ====================
    sections = {
        -- lualine_a = { 'mode' },
        lualine_b = {
            { 'branch', icon = '' },
        },
        lualine_c = {
            { 'diff', symbols = { added = ' ', modified = ' ', removed = ' ' } },
            {
                'diagnostics',
                sources = { 'nvim_diagnostic' },
                symbols = { error = ' ', warn = ' ', info = ' ', hint = ' ' },
            },
        },
        -- lualine_x = {'encoding', 'fileformat', 'filetype'},
        -- lualine_y = { 'progress' },
        -- lualine_z = { 'location' }
    },

    inactive_sections = {},

    -- ==================== Winbar ====================
    winbar = {
        lualine_c = {
            {
                'filename',
                file_status = true, -- [关键设置] 启用文件状态显示
                path = 2, -- 可选: 0 = 仅文件名, 1 = 相对路径, 2 = 绝对路径
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

    extensions = { 'quickfix', 'toggleterm', 'fugitive' },
})

-- 图标
return {
    {
        'nvim-mini/mini.icons',
        lazy = false,
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
}

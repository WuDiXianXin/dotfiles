vim.pack.add({
    {
        src = 'https://github.com/nvim-mini/mini.nvim',
        branch = 'main',
    },
})
-- ==================== Icons & 整合 ====================
-- 配置 mini.icons
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

-- ==================== 核心编辑体验 ====================
require('mini.surround').setup()
require('mini.ai').setup({
    -- 建议把搜索范围调大一点，避免找不到的情况
    n_lines = 500,
    -- 很多人喜欢这个搜索策略
    search_method = 'cover_or_next',
})
require('mini.pairs').setup()
require('mini.indentscope').setup({
    symbol = '▏', -- 或 '│' 等细线
    options = {
        try_as_border = true, -- ★ 必须！让头部行（如 if/for/def）被识别为边界，从而能缩小到内层
        indent_at_cursor = true, -- 光标左右移动时动态调整参考缩进
        border = 'both',
    },
    draw = {
        delay = 50,
        animation = require('mini.indentscope').gen_animation.none(), -- 关动画，避免延迟迷惑
        predicate = function()
            return true
        end, -- 测试阶段强制画所有（可选）
    },
})

-- ==================== 文件 & 导航 ====================
require('mini.files').setup({
    windows = {
        preview = true,
        width_focus = 25,
        width_preview = 80,
    },
})
require('mini.pick').setup()
require('mini.extra').setup()

-- ==================== 美观 & 辅助 ====================
require('mini.hipatterns').setup({
    highlighters = {
        -- 经典四件套
        fixme = { pattern = '%f[%w]()FIXME()%f[%W]', group = 'MiniHipatternsFixme' },
        hack = { pattern = '%f[%w]()HACK()%f[%W]', group = 'MiniHipatternsHack' },
        todo = { pattern = '%f[%w]()TODO()%f[%W]', group = 'MiniHipatternsTodo' },
        note = { pattern = '%f[%w]()NOTE()%f[%W]', group = 'MiniHipatternsNote' },

        -- 十六进制颜色
        hex_color = require('mini.hipatterns').gen_highlighter.hex_color(),

        -- 日志级别
        log_error_multi = { pattern = { '%[ERROR%]', 'ERROR:', 'ERROR%s*-' }, group = 'DiagnosticError' },
        log_warn_multi = { pattern = { '%[WARN%]', 'WARN:', 'WARN%s*-' }, group = 'DiagnosticWarn' },
        log_info_multi = { pattern = { '%[INFO%]', 'INFO:', 'INFO%s*-' }, group = 'DiagnosticInfo' },
        log_debug_multi = { pattern = { '%[DEBUG%]', 'DEBUG:', 'DEBUG%s*-' }, group = 'DiagnosticHint' },
    },

    delay = { text_change = 50, scroll = 25 },
})

require('mini.tabline').setup()

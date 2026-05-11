vim.pack.add({
    {
        src = 'https://github.com/folke/which-key.nvim',
        branch = 'main',
    },
})

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

-- ==================== 分组注册（推荐新写法：wk.add） ====================
wk.add({
    -- Leader 顶级分组
    { '<leader>', group = 'Leader' },

    -- 功能大类
    -- { '<leader>a', group = 'AI / Avante' },
    { '<leader>b', group = '缓冲区管理' },
    { '<leader>c', group = ' Crates' },
    { '<leader>d', group = '诊断 / Debug / DAP' },
    { '<leader>f', group = 'Pick' },
    -- { '<leader>g', group = '󰊢  Git' },
    { '<leader>r', group = 'Run' },
    { '<leader>l', group = 'fmt / 位置列表' },
    { '<leader>m', group = 'Markdown 渲染' },
    { '<leader>t', group = '测试' },

    -- 非 Leader 前缀
    { 'g', group = '跳转' },
    { 'gr', group = 'LSP' },
    { '[', group = '上一个' },
    { ']', group = '下一个' },
})

-- 全局快捷键查看（? 键）
vim.keymap.set('n', '?', function()
    wk.show({ global = true })
end, { desc = '查看所有快捷键 (WhichKey)' })

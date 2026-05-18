vim.pack.add({
    {
        src = 'https://github.com/folke/tokyonight.nvim',
        branch = 'main',
    },
})

require('tokyonight').setup({
    -- transparent = true, -- 开启主题自带透明背景
})
vim.cmd([[colorscheme tokyonight-moon]])

-- local function _set_transparent()
--     local transparent_groups = {
--         -- 'Normal', -- 当前光标所在窗口的编辑区域
--         -- 'NormalNC', -- 非当前光标所在窗口的编辑区域
--         -- 'SignColumn', -- 符号列（诊断图标）
--         -- 'LineNr', -- 行号
--         -- 'CursorLineNr', -- 光标行号
--         -- 'CursorLine', -- 光标行
--         'FloatNormal', -- 浮动窗口内容
--         'FloatBorder', -- 浮动窗口边框
--         'WinBar',
--         'WinBarNC',
--         'TabLine',  -- 未选中标签（若需要标签栏透明可保留，不需要可删除）
--         'TabLineSel', -- 选中标签（若需要标签栏透明可保留，不需要可删除）
--         'TabLineFill', -- 标签栏空白区域（若需要标签栏透明可保留，不需要可删除）
--         'StatusLine', -- 当前窗口底部状态栏（核心：实现底部状态栏透明）
--         'StatusLineNC', -- 非当前窗口底部状态栏（核心：分屏时状态栏透明统一）
--         'MiniTablineFill',
--         'MiniTablineCurrent',
--         'MiniTablineVisible',
--         'MiniTablineHidden',
--         -- 'MiniTablineModifiedCurrent',
--         -- 'MiniTablineModifiedVisible',
--         -- 'MiniTablineModifiedHidden',
--     }
--
--     for _, group in ipairs(transparent_groups) do
--         vim.api.nvim_set_hl(0, group, { bg = 'none' })
--     end
-- end
--
-- _set_transparent()

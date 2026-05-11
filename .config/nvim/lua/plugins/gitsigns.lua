vim.pack.add({
    {
        src = 'https://github.com/lewis6991/gitsigns.nvim',
        branch = 'main',
    },
})

local status_ok, gitsigns = pcall(require, 'gitsigns')
if not status_ok then
    vim.notify('gitsigns.nvim 加载失败！', vim.log.levels.ERROR)
    return
end
local colors = require('tokyonight.colors').setup({ transparent = true })
vim.api.nvim_set_hl(0, 'GitSignsAdd', { fg = colors.git.add })
vim.api.nvim_set_hl(0, 'GitSignsChange', { fg = colors.git.change })
vim.api.nvim_set_hl(0, 'GitSignsDelete', { fg = colors.git.delete })
vim.api.nvim_set_hl(0, 'GitSignsTopDelete', { fg = colors.git.delete })
vim.api.nvim_set_hl(0, 'GitSignsChangeDelete', { fg = colors.warning })
vim.api.nvim_set_hl(0, 'GitSignsUntracked', { fg = colors.comment })

gitsigns.setup({
    -- 未暂存（unstaged）变更符号
    signs = {
        add = { text = '┃' },
        change = { text = '┃' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
        untracked = { text = '┆' },
    },
    -- 已暂存（staged）变更符号
    signs_staged = {
        add = { text = '⊕' },
        change = { text = '⊛' },
        delete = { text = '⊖' },
        topdelete = { text = '⊤' },
        changedelete = { text = '⊚' },
        -- untracked = { text = '┆' },
    },
    signs_staged_enable = true, -- 主动启用暂存区符号显示（默认关闭）
    -- 可通过命令切换
    signcolumn = true, -- 显示符号列（默认开启）
    numhl = true, -- 高亮变更行的行号（便于快速定位变更）
    linehl = false, -- 关闭整行高亮（避免界面过于杂乱）
    word_diff = false, -- 关闭单词级内联diff（保持界面简洁）
    -- Git 目录监控配置
    watch_gitdir = {
        interval = 1000, -- 1秒监控一次
        follow_files = true, -- 跟随文件重命名/移动
    },
    auto_attach = true, -- 自动为缓冲区附加 gitsigns 功能
    attach_to_untracked = true, -- 为未追踪文件也启用（显示 untracked 符号）
    current_line_blame = false, -- 默认关闭行内 blame（按需开启，减少性能消耗）
    current_line_blame_opts = {
        virt_text = true,
        virt_text_pos = 'eol', -- 'eol' | 'overlay' | 'right_align'
        delay = 1000,
        ignore_whitespace = false,
        virt_text_priority = 100,
        use_focus = true,
    },
    current_line_blame_formatter = '<author>, <author_time:%R> - <summary>',
    blame_formatter = nil, -- Use default
    sign_priority = 6,
    update_debounce = 200,
    status_formatter = nil, -- 禁用默认状态格式化（让 heirline 处理）
    max_file_length = 40000, -- 大文件禁用（避免卡顿）
    preview_config = {
        -- 变更预览窗口配置（简洁美观）
        style = 'minimal',
        relative = 'cursor',
        row = 0,
        col = 1,
    },
})

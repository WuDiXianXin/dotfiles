-- 创建分组
local api = vim.api
local autocmd = api.nvim_create_autocmd
local augroup = api.nvim_create_augroup

-- 1. 通用编辑体验组 (General)
-- 功能：复制高亮、光标恢复、注释格式等
augroup('General', { clear = true })

-- 2. LSP 相关组 (LSP)
augroup('LSP', { clear = true })

-- 3. UI/界面显示组 (UI)
-- augroup('UI', { clear = true })

-- General 组：通用编辑体验
autocmd('TextYankPost', {
    group = 'General',
    desc = '复制文本后高亮提示',
    callback = function()
        -- 300ms 高亮，颜色同搜索
        vim.hl.on_yank({ higroup = 'IncSearch', timeout = 300 })
        -- vim.hl.hl_op({ higroup = 'IncSearch', timeout = 300 })
    end,
})

autocmd({ 'BufReadPost' }, {
    group = 'General',
    desc = '打开文件自动恢复上次光标位置 + 展开折叠',
    callback = function()
        api.nvim_exec2('silent! normal! g`"zv', { output = false })
    end,
})

-- autocmd('BufEnter', {
--     group = 'General',
--     desc = '禁用新行自动延续注释格式',
--     callback = function()
--         vim.opt_local.formatoptions:remove({ 'c', 'r', 'o' })
--     end,
-- })

-- UI 组：界面显示相关
-- autocmd('BufWinEnter', {
--     group = 'UI',
--     desc = '禁用 dap-ui 的窗口 winbar',
--     pattern = '*',
--     callback = function()
--         -- 'dapui_scopes',
--         -- 'dapui_breakpoints',
--         -- 'dapui_stacks',
--         -- 'dapui_watches',
--         -- 'dapui_repl',
--         -- 'dapui_console',
--
--         -- 'dap-repl',
--
--         local ft = vim.bo.filetype
--         if ft == 'dap-repl' then
--             vim.opt_local.winbar = ''
--         end
--     end,
-- })

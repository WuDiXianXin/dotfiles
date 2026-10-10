local bufnr = vim.api.nvim_get_current_buf()
local keymap = require('utils.keymap').bufmap(bufnr)
local nmap = keymap.nmap
local vmap = keymap.vmap

-- ==================== Lua 开发专用 ====================

-- 执行当前行
nmap('<space>x', function()
    local line = vim.api.nvim_get_current_line()
    local ok, err = pcall(vim.cmd, 'lua ' .. line)
    if not ok then
        vim.notify('Lua 错误: ' .. err, vim.log.levels.ERROR)
    end
end, '运行当前行 Lua 代码（带错误提示）')

-- 执行选中区域
vmap('<space>x', ':lua<CR>', '运行选中的 Lua 代码')

local bufnr = vim.api.nvim_get_current_buf()
local map = function(mode, lhs, rhs, desc, extra_opts)
    local options =
        vim.tbl_extend('force', { noremap = true, silent = true, nowait = true, buffer = bufnr }, extra_opts or {})
    if desc then
        options.desc = desc
    end
    vim.keymap.set(mode, lhs, rhs, options)
end

local nmap = function(lhs, rhs, desc, opts)
    map('n', lhs, rhs, desc, opts)
end
local vmap = function(lhs, rhs, desc, opts)
    map('v', lhs, rhs, desc, opts)
end

-- ==================== Lua 开发专用 ====================

-- 执行整个 buffer
nmap('<leader>X', function()
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    local code = table.concat(lines, '\n')
    local chunk, load_err = load(code, '=(buffer)')
    if not chunk then
        vim.notify('Lua 加载错误: ' .. load_err, vim.log.levels.ERROR)
        return
    end
    local ok, run_err = pcall(chunk)
    if not ok then
        vim.notify('Lua 运行错误: ' .. run_err, vim.log.levels.ERROR)
    else
        vim.notify('✓ 执行完成', vim.log.levels.INFO)
    end
end, '执行整个 buffer 的 Lua 代码')

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

-- 调试打印
nmap('<space>p', function()
    local cword = vim.fn.expand('<cword>')
    local ok, res = pcall(vim.fn.luaeval, cword)
    if ok then
        vim.notify(vim.inspect(res), vim.log.levels.INFO)
    else
        vim.cmd('lua print(vim.inspect(' .. cword .. '))')
    end
end, '打印当前 word 的 vim.inspect')

vmap('<space>p', function()
    local lines = vim.fn.getregion(vim.fn.getpos("'<"), vim.fn.getpos("'>"), { type = vim.fn.mode() })
    vim.notify(vim.inspect(table.concat(lines, '\n')), vim.log.levels.INFO)
end, '打印选中内容的 vim.inspect')

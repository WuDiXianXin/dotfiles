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

-- 1. 加载（source）当前 Lua 文件（最常用：改 Neovim 配置后立即生效）
nmap('<space>X', '<cmd>source %<CR>', 'nvim: 加载当前 Lua 文件配置')

-- 2. 执行当前行 Lua 代码（更安全、一致的方式）
nmap('<space>x', function()
  local line = vim.api.nvim_get_current_line()
  local ok, err = pcall(vim.cmd, 'lua ' .. line)
  if not ok then
    vim.notify('Lua 错误: ' .. err, vim.log.levels.ERROR)
  end
end, '运行当前行 Lua 代码（带错误提示）')

-- 3. 执行视觉模式选中的 Lua 代码（原方式已很好）
vmap('<space>x', ':<C-u>lua<CR>', '运行选中的 Lua 代码')

-- 4. 打印选中内容或当前 word 的 vim.inspect 结果（超级实用调试神器）
nmap('<space>p', function()
  local cword = vim.fn.expand('<cword>')
  vim.cmd('lua print(vim.inspect(' .. cword .. '))')
end, '打印当前 word 的 vim.inspect 结果')

vmap('<space>p', function()
  vim.cmd("'<'<,'>lua print(vim.inspect(vim.fn.getreg('*')))")
end, '打印选中内容的 vim.inspect 结果', { silent = false })

-- 5. 快速执行整个 buffer 的代码（不 source，仅运行）
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
  end
end, '执行整个 buffer 的 Lua 代码（不 source）')

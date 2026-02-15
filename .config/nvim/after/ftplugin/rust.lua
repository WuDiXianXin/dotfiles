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

nmap('gra', function()
  vim.cmd.RustLsp('codeAction')
end, 'Rust: 代码动作（支持分组）')
nmap('K', function()
  vim.cmd.RustLsp({ 'hover', 'actions' })
end, 'Rust: 悬浮信息 + 动作')

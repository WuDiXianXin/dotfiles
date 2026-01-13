local bufnr = vim.api.nvim_get_current_buf()
local function map(mode, lhs, rhs, desc, extra_opts)
  local options =
      vim.tbl_extend('force', { noremap = true, silent = true, nowait = true, buffer = bufnr }, extra_opts or {})
  if desc then
    options.desc = desc
  end
  vim.keymap.set(mode, lhs, rhs, options)
end

local function nmap(lhs, rhs, desc, opts)
  map('n', lhs, rhs, desc, opts)
end

-- ===================== 核心 LSP 增强（覆盖通用键位） =====================
nmap('gra', function()
  vim.cmd.RustLsp('codeAction')
end, 'Rust: 代码动作（支持分组）')
nmap('K', function()
  vim.cmd.RustLsp({ 'hover', 'actions' })
end, 'Rust: 悬浮信息 + 动作')

-- ===================== 运行 & 测试 =====================
nmap('<leader>rr', function()
  vim.cmd.RustLsp('runnables')
end, 'Rust: 选择并运行 Runnable')
nmap('<leader>rR', function()
  vim.cmd.RustLsp({ 'runnables', bang = true })
end, 'Rust: 重跑上一个 Runnable')
nmap('<leader>tt', function()
  vim.cmd.RustLsp('testables')
end, 'Rust: 选择并运行测试')
nmap('<leader>tT', function()
  vim.cmd.RustLsp({ 'testables', bang = true })
end, 'Rust: 重跑上一个测试')

-- ===================== 宏 & 代码结构 =====================
nmap('<leader>em', function()
  vim.cmd.RustLsp('expandMacro')
end, 'Rust: 递归展开宏')
nmap('<leader>jl', function()
  vim.cmd.RustLsp('joinLines')
end, 'Rust: 智能连接行')

-- ===================== Cargo & 依赖 =====================
nmap('<leader>ro', function()
  vim.cmd.RustLsp('openCargo')
end, 'Rust: 打开 Cargo.toml')
nmap('<leader>rc', function()
  vim.cmd.RustLsp('reloadWorkspace')
end, 'Rust: 重载 Workspace')
nmap('<leader>od', function()
  vim.cmd.RustLsp('openDocs')
end, 'Rust: 打开 docs.rs 文档')

-- ===================== 诊断 & 错误解释 =====================
nmap('<leader>ee', function()
  vim.cmd.RustLsp({ 'explainError', 'cycle' })
end, 'Rust: 循环解释错误')
nmap('<leader>rdg', function()
  vim.cmd.RustLsp('renderDiagnostic')
end, 'Rust: 显示当前详细诊断')
nmap('<leader>fc', function()
  vim.cmd.RustLsp({ 'flyCheck', 'run' })
end, 'Rust: 手动运行 flyCheck (check/clippy)')

-- ===================== 导航 =====================
nmap('<leader>pm', function()
  vim.cmd.RustLsp('parentModule')
end, 'Rust: 跳转到父模块')

-- -- ===================== 高级视图（需要 nightly rustc 时可用） =====================
-- nmap('<leader>vh', function() vim.cmd.RustLsp({ 'view', 'hir' }) end, 'Rust: 查看 HIR')
-- nmap('<leader>vm', function() vim.cmd.RustLsp({ 'view', 'mir' }) end, 'Rust: 查看 MIR')
-- nmap('<leader>st', function() vim.cmd.RustLsp('syntaxTree') end, 'Rust: 查看语法树')

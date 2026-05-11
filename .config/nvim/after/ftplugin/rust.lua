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

-- ===================== 核心 LSP 增强 =====================
nmap('gra', function()
    vim.cmd.RustLsp('codeAction')
end, 'Rust: 代码动作（支持分组）')

nmap('K', function()
    vim.cmd.RustLsp({ 'hover', 'actions' })
end, 'Rust: 悬浮信息 + 动作')

-- ===================== 调试 =====================
nmap('<leader>dd', function()
    vim.cmd.RustLsp('debuggables')
end, 'Rust: 调试。')

nmap('<leader>dd', function()
    vim.cmd.RustLsp({ 'debuggables', bang = true })
end, 'Rust: 运行上一个调试。')

-- ===================== 运行 =====================
nmap('<leader>rr', function()
    vim.cmd.RustLsp('runnables')
end, 'Rust: 选择并运行 Runnable')

nmap('<leader>rR', function()
    vim.cmd.RustLsp({ 'runnables', bang = true })
end, 'Rust: 重跑上一个 Runnable')

-- ===================== 测试 =====================
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
nmap('<leader>or', function()
    vim.cmd.RustLsp('openCargo')
end, 'Rust: 打开 Cargo.toml')
nmap('<leader>rw', function()
    vim.cmd.RustLsp('reloadWorkspace')
end, 'Rust: 重载 Workspace')
nmap('<leader>od', function()
    vim.cmd.RustLsp('openDocs')
end, 'Rust: 打开 docs.rs 文档')

-- ===================== 导航 =====================
nmap('<leader>pm', function()
    vim.cmd.RustLsp('parentModule')
end, 'Rust: 跳转到父模块')

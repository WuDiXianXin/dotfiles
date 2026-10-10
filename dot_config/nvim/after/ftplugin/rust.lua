local bufnr = vim.api.nvim_get_current_buf()
local keymap = require('utils.keymap').bufmap(bufnr)
local nmap = keymap.nmap

-- ===================== 核心 LSP 增强 =====================

nmap('gra', function()
    vim.cmd.RustLsp('codeAction')
end, 'Rust: 代码动作（支持分组）')

nmap('K', function()
    vim.cmd.RustLsp({ 'hover', 'actions' })
end, 'Rust: 悬浮信息 + 动作')

-- ===================== 运行 =====================

nmap('<leader>rr', function()
    vim.cmd.RustLsp('runnables')
end, 'Rust: 选择并运行 Runnable')

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

-- ==================== Rust 专用 which-key 分组 ====================
require('which-key').add({
    { '<leader>j', group = 'Rust: 连接行', buffer = bufnr },
    { '<leader>p', group = 'Rust: 父模块', buffer = bufnr },
    { '<leader>r', group = 'Rust: 运行', buffer = bufnr },
    { '<leader>e', group = 'Rust: 宏/编辑', buffer = bufnr },
    { '<leader>o', group = 'Rust: 打开', buffer = bufnr },
})

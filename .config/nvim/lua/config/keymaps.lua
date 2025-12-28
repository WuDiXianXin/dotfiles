-- ==================== 全局键位映射工具函数 ====================
local map = function(mode, lhs, rhs, desc, extra_opts)
  local options = vim.tbl_extend(
    'force',
    { noremap = true, silent = true, nowait = true },
    extra_opts or {}
  )
  if desc then
    options.desc = desc
  end
  vim.keymap.set(mode, lhs, rhs, options)
end

-- 快捷别名（可选，写起来更短）
local nmap = function(lhs, rhs, desc, opts)
  map('n', lhs, rhs, desc, opts)
end
local vmap = function(lhs, rhs, desc, opts)
  map('v', lhs, rhs, desc, opts)
end
local imap = function(lhs, rhs, desc, opts)
  map('i', lhs, rhs, desc, opts)
end
local nvmap = function(lhs, rhs, desc, opts)
  map({ 'n', 'v' }, lhs, rhs, desc, opts)
end
local xmap = function(lhs, rhs, desc, opts)
  map('x', lhs, rhs, desc, opts)
end

-- 如果某些映射需要显示命令行（比如 :set list!），可传入 silent = false
local noisy = { silent = false }

-- ==================== 基础设置 ====================
-- 默认 1000
-- vim.opt.timeoutlen = 500
-- vim.opt.ttimeoutlen = 500

-- ==================== 基础编辑映射 ====================
nmap(' ', '<Nop>', '禁用空格默认功能（用作 Leader）')
nmap('<CR>', '<Nop>', '禁用回车默认功能')

nvmap('<C-s>', function()
  local mode = vim.api.nvim_get_mode().mode
  vim.cmd('noautocmd w')
  if mode == 'i' then
    vim.cmd('startinsert')
  end
end, '纯净保存文件（支持普通/插入模式）')

nmap('<leader>tn', ':tabnew<CR>', '新建空白标签页')
nmap('<leader>to', '<C-w>T', '当前窗口独立为新标签页')
nmap('<leader>tc', ':tabclose<CR>', '关闭当前标签页')

nmap('wk', '<cmd>resize +2<CR>', '增加窗口高度')
nmap('wj', '<cmd>resize -2<CR>', '减少窗口高度')
nmap('wh', '<cmd>vertical resize -2<CR>', '减少窗口宽度')
nmap('wl', '<cmd>vertical resize +2<CR>', '增加窗口宽度')

nmap('wv', '<C-w>v', '垂直分屏（右侧）')
nmap('ws', '<C-w>s', '水平分屏（下方）')
nmap('wd', '<C-w>c', '关闭当前窗口')

nmap('gh', '<C-w>h', '切换到左侧窗口')
nmap('gl', '<C-w>l', '切换到右侧窗口')
nmap('gk', '<C-w>k', '切换到上方窗口')
nmap('gj', '<C-w>j', '切换到下方窗口')

nmap('wm', function()
  local win = vim.api.nvim_get_current_win()
  local cfg = vim.api.nvim_win_get_config(win)
  if cfg.relative == '' then
    vim.api.nvim_win_set_config(win, {
      relative = 'editor',
      width = vim.o.columns,
      height = vim.o.lines - 1,
      row = 0,
      col = 0,
      border = 'rounded',
    })
  else
    vim.api.nvim_win_set_config(win, { relative = '' })
  end
end, '当前窗口全屏/还原切换')

nmap('we', '<cmd>wincmd =<CR>', '所有窗口等分大小')

nmap('<C-d>', '<C-d>zz', '向下半屏并居中')
nmap('<C-u>', '<C-u>zz', '向上半屏并居中')
nmap('n', 'nzzzv', '下一个搜索结果并居中展开')
nmap('N', 'Nzzzv', '上一个搜索结果并居中展开')

nmap('x', '"_x', '删除字符（不污染寄存器）')
nmap('X', '"_X', '删除前字符（不污染寄存器）')
nmap('dd', '"_dd', '删除行（不污染寄存器）')
nmap('D', '"_D', '删除到行尾（不污染寄存器）')
vmap('d', '"_d', '视觉模式删除（不污染寄存器）')
vmap('x', '"_d', '视觉模式 x 删除（兼容习惯）')

imap('kj', '<Esc>', '快速退出插入模式')

nmap('<leader>cp', ':normal! ggVG"_dP<CR>', '替换全文为剪贴板内容')

xmap('<', '<gv', '视觉模式减少缩进（保留选中）')
xmap('>', '>gv', '视觉模式增加缩进（保留选中）')

nvmap('j', 'gj', '视觉行向下移动')
nvmap('k', 'gk', '视觉行向上移动')

nmap('<A-k>', ':m .-2<CR>==', '当前行上移并自动缩进')
nmap('<A-j>', ':m .+1<CR>==', '当前行下移并自动缩进')
vmap('<A-k>', ":m '<-2<CR>gv=gv", '选中行上移并自动缩进')
vmap('<A-j>', ":m '>+1<CR>gv=gv", '选中行下移并自动缩进')

-- ==================== 终端映射 ====================
nmap('t', ':sp | term<CR>i', '水平分屏打开终端')
nmap('T', ':vsp | term<CR>i', '垂直分屏打开终端')

-- ==================== 缓冲区管理 ====================
nmap('<leader>bb', ':e #<CR>', '切换到交替缓冲区')
nmap('<leader>bp', ':bprevious<CR>', '上一个缓冲区')
nmap('<leader>bn', ':bnext<CR>', '下一个缓冲区')
nmap('<leader>bd', ':bdelete<CR>', '删除当前缓冲区')
nmap('<leader>bD', ':bdelete!<CR>', '强制删除当前缓冲区')

-- ==================== 显示/功能切换 ====================
nmap('<C-l>', '<Cmd>nohlsearch<CR>', '清除搜索高亮', noisy)
nmap('<leader>ws', ':set list!<CR>', '切换空白字符显示', noisy)

-- ==================== 诊断 & LSP 相关 ====================
nmap('<leader>d', function()
  vim.diagnostic.open_float({
    focusable = false,
    close_events = { 'BufLeave', 'CursorMoved' },
    source = 'always',
    prefix = ' ',
  })
end, '查看当前行诊断（浮动窗口）')

nmap('<leader>D', function()
  vim.diagnostic.open_float({
    focusable = true, -- 可以聚焦
    border = 'rounded',
    source = 'always',
    prefix = ' ',
    scope = 'cursor', -- 默认只显示光标下诊断，可改 'line' 或 'buffer'
  })
end, '查看当前行诊断（浮动窗口，可聚焦复制）')

nmap(
  '<leader>q',
  vim.diagnostic.setloclist,
  '所有诊断填充到位置列表'
)
nmap('<leader>l', function()
  local winid = vim.fn.getloclist(0, { winid = 0 }).winid
  if winid == 0 then
    vim.cmd('lopen')
  else
    vim.cmd('lclose')
  end
end, '打开/关闭位置列表')

nmap('[l', ':lprev<CR>', '位置列表上一个')
nmap(']l', ':lnext<CR>', '位置列表下一个')

nmap('[d', function()
  if vim.diagnostic.get_prev() then
    vim.diagnostic.jump({ count = -1 })
  end
end, '上一个诊断（安全）')

nmap(']d', function()
  if vim.diagnostic.get_next() then
    vim.diagnostic.jump({ count = 1 })
  end
end, '下一个诊断（安全）')

nmap('K', vim.lsp.buf.hover, '显示悬浮文档')
nmap('grd', vim.lsp.buf.definition, '跳转定义')
nmap('grD', vim.lsp.buf.declaration, '跳转声明')
nmap('grr', vim.lsp.buf.references, '查找所有引用')
nmap('gri', vim.lsp.buf.implementation, '跳转实现')
nmap('grn', vim.lsp.buf.rename, '全局重命名')
nmap('gra', vim.lsp.buf.code_action, '代码动作')
nmap('grt', vim.lsp.buf.type_definition, '跳转类型定义')
nmap('<leader>lf', vim.lsp.buf.format, '格式化当前文件')

-- ==================== Mini.nvim 相关 ====================
nmap('<leader>ff', ':Pick files<CR>', '查找文件')
nmap('<leader>fb', ':Pick buffers<CR>', '查找缓冲区')
nmap('<leader>fg', ':Pick grep_live<CR>', '实时文本搜索')
nmap('<leader>fG', ':Pick grep<CR>', '静态文本搜索')
nmap('<leader>fr', ':Pick resume<CR>', '恢复上次查找')
nmap('<leader>fh', ':Pick help<CR>', '搜索帮助文档')
nmap('<leader>e', ':lua MiniFiles.open()<CR>', '打开文件管理器')

-- ==================== Markview.nvim 相关 ====================
nmap('<leader>M', '<cmd>Markview<cr>', 'Toggle Markview preview');
nmap('<leader>m', '<cmd>Markview toggle<cr>', 'Toggle Markview');
nmap('<leader>ms', '<cmd>Markview splitToggle<cr>', 'Markview split view');

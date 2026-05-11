-- ==================== 全局键位映射工具函数 ====================

local map = function(mode, lhs, rhs, desc, extra_opts)
  local options = vim.tbl_extend('force', { noremap = true, silent = true, nowait = true }, extra_opts or {})
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
local xmap = function(lhs, rhs, desc, opts)
  map('x', lhs, rhs, desc, opts)
end
local nxmap = function(lhs, rhs, desc, opts)
  map({ 'n', 'x' }, lhs, rhs, desc, opts)
end

-- ==================== 基础设置 ====================

-- 默认 1000
vim.opt.timeoutlen = 300
vim.opt.ttimeoutlen = 300

nmap(' ', '<Nop>', '禁用空格默认功能（用作 Leader）')
nmap('<CR>', '<Nop>', '禁用回车默认功能')

nmap('<leader>!', ':!', '快速进入 :!')
nmap('<leader>;', ':!', '快速进入 :!')

nmap('<leader>j', '*``cgn', '替换光标所在单词（按 . 继续下一个）')
nmap('<leader>r', ':%s/', '快速提供替换命令')

-- ==================== 搜索与预览 ====================

nmap('<C-d>', '<C-d>zz', '向下半屏并居中')
nmap('<C-u>', '<C-u>zz', '向上半屏并居中')

nmap('<C-f>', '<C-f>zz', '向下全屏并居中')
nmap('<C-b>', '<C-b>zz', '向下全屏并居中')

nmap('n', 'nzzzv', '下一个搜索结果并居中展开')
nmap('N', 'Nzzzv', '上一个搜索结果并居中展开')

nmap('<C-l>', '<cmd>nohlsearch<cr>', '清除搜索高亮')

nmap('<leader>tl', '<cmd>set list!<CR>', '切换空白字符显示')

map('n', '<leader>df', '<cmd>diffthis<CR>')

-- toggle editor visuals（编辑器视觉/功能切换）
nmap('<leader>ts', '<cmd>set spell!<CR>', '切换拼写检查（spell）')
nmap('<leader>tw', '<cmd>set wrap!<CR>', '切换自动换行（wrap）')
nmap('<leader>tcc', '<cmd>set cursorcolumn!<CR>', '切换光标列高亮（cursorcolumn）')
nmap('<leader>th', '<cmd>set hlsearch!<CR>', '切换搜索高亮（hlsearch）')
nmap('<leader>tr', '<cmd>set relativenumber!<CR>', '切换相对行号（relativenumber）')

-- ==================== 文本与文件操作 ====================

nxmap('<C-s>', function()
  local mode = vim.api.nvim_get_mode().mode
  vim.cmd('noautocmd w')
  if mode == 'i' then
    vim.cmd('startinsert')
  end
end, '纯净保存文件（支持普通/插入模式）')

map({ 'i', 't' }, 'kj', '<Esc>', '快速退出插入模式')
map({ 'i', 't' }, 'jk', '<Esc>', '快速退出插入模式')

nmap('<leader>y', '"+y', '复制到系统剪贴板')
xmap('y', '"+y', '复制到系统剪贴板')
nmap('<leader>Y', '"+Y', '整行复制到系统剪贴板')

xmap('<', '<gv', '视觉模式减少缩进（保留选中）')
xmap('>', '>gv', '视觉模式增加缩进（保留选中）')

nxmap('j', "v:count == 0 ? 'gj' : 'j'", '视觉行向下移动（有计数则跳转物理行）', { expr = true })
nxmap('k', "v:count == 0 ? 'gk' : 'k'", '视觉行向上移动（有计数则跳转物理行）', { expr = true })

nmap('<A-k>', '<cmd>m .-2<CR>==', '当前行上移并自动缩进')
nmap('<A-j>', '<cmd>m .+1<CR>==', '当前行下移并自动缩进')
vmap('<A-k>', "<cmd>m '<-2<CR>gv=gv", '选中行上移并自动缩进')
vmap('<A-j>', "<cmd>m '>+1<CR>gv=gv", '选中行下移并自动缩进')

-- ==================== tab ====================

nmap('<leader>tn', '<cmd>tabnew<CR>', '新建空白标签页')
nmap('<leader>to', '<C-w>T', '当前窗口独立为新标签页')
nmap('<leader>tc', '<cmd>tabclose<CR>', '关闭当前标签页')

-- ==================== 窗口 ====================

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

nmap('gwh', '<C-w>H', '移动窗口（到最左侧）')
nmap('gwl', '<C-w>L', '移动窗口（到最右侧）')
nmap('gwk', '<C-w>K', '移动窗口（到最上侧）')
nmap('gwj', '<C-w>J', '移动窗口（到最下侧）')

nmap('we', '<cmd>wincmd =<CR>', '所有窗口等分大小')

-- ==================== 终端映射 ====================

map('t', '<leader><Esc>', '<C-\\><C-n>', '终端模式：快速退出到普通t模式')
nmap('t', '<cmd>term<CR>i', '进入终端模式')

-- ==================== 缓冲区管理 ====================

nmap('<leader>bb', '<cmd>e #<CR>', '切换到交替缓冲区')
nmap('<leader>bd', '<cmd>bdelete<CR>', '删除当前缓冲区')
nmap('<leader>bD', '<cmd>bdelete!<CR>', '强制删除当前缓冲区')
nmap('<leader>bl', '<cmd>ls<CR>', '查看缓冲区文件')

-- ==================== 诊断 & LSP 相关 ====================

nmap('<leader>q', vim.diagnostic.setloclist, '所有诊断填充到位置列表')
nmap('<leader>l', function()
  local winid = vim.fn.getloclist(0, { winid = 0 }).winid
  if winid == 0 then
    vim.cmd('lopen')
  else
    vim.cmd('lclose')
  end
end, '打开/关闭位置列表')
nmap('<leader>lg', ':lvimgrep', '精准导航搜索 → 位置列表')

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

nmap('<leader>f', ':Pick', '查找 / Pickers')
nmap('<leader>ff', '<cmd>Pick files<CR>', '查找文件')
nmap('<leader>fb', '<cmd>Pick buffers<CR>', '查找缓冲区')
nmap('<leader>fg', '<cmd>Pick grep_live<CR>', '实时文本搜索')
nmap('<leader>fG', '<cmd>Pick grep<CR>', '静态文本搜索')
nmap('<leader>fr', '<cmd>Pick resume<CR>', '恢复上次查找')
nmap('<leader>fh', '<cmd>Pick help<CR>', '搜索帮助文档')
nmap('<leader>e', '<cmd>lua MiniFiles.open()<CR>', '打开文件管理器')

-- ==================== Markview.nvim 相关 ====================

nmap('<leader>M', '<cmd>Markview<cr>', '全局完全开关 markview 渲染（包括所有缓冲区）')
nmap('<leader>m', '<cmd>Markview toggle<cr>', '只切换当前 Markdown 文件的渲染')
nmap('<leader>ms', '<cmd>Markview splitToggle<cr>', '打开/关闭分屏实时预览')

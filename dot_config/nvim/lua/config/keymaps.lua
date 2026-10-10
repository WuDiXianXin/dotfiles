local nmap = require('utils.keymap').nmap
local vmap = require('utils.keymap').vmap
local xmap = require('utils.keymap').xmap
-- local nxmap = require('utils.keymap').nxmap
local imap = require('utils.keymap').imap

-- ==================== 基础设置 ====================

nmap(' ', '<Nop>', 'Leader')
-- nmap('<CR>', '<Nop>', '禁用回车默认功能')

nmap('<leader>la', ':Lazy<CR>', '打开 Lazy 面板')

nmap('<leader>;', ':!', '快速进入 :!')

nmap('<leader>r', '*``cgn', '替换光标所在单词（按 . 继续下一个）')
nmap('<leader>R', [[:%s/\<<C-r><C-w>\>/]], '全文替换当前单词')

-- ==================== 搜索与预览 ====================

nmap('<C-d>', '<C-d>zz', '向下半屏并居中')
nmap('<C-u>', '<C-u>zz', '向上半屏并居中')

nmap('<C-f>', '<C-f>zz', '向下全屏并居中')
nmap('<C-b>', '<C-b>zz', '向上全屏并居中')

nmap('n', 'nzzzv', '下一个搜索结果并居中展开')
nmap('N', 'Nzzzv', '上一个搜索结果并居中展开')

nmap('<leader>tl', '<cmd>set list!<CR>', '切换空白字符显示')
nmap('<leader>tt', function()
    vim.g.transparent = not vim.g.transparent
    vim.cmd('Lazy reload tokyonight.nvim')
end, '切换透明')

nmap('<leader>gdt', '<cmd>diffthis<CR>', '对比文件')
nmap('<leader>gdo', '<cmd>diffoff<CR>', '取消对比')

-- ==================== 文本与文件操作 ====================

xmap('p', [["_dP]], '粘贴（黑洞版）')

imap('kj', '<Esc>', '快速退出插入模式')
imap('jk', '<Esc>', '快速退出插入模式')

xmap('<', '<gv', '视觉模式减少缩进（保留选中）')
xmap('>', '>gv', '视觉模式增加缩进（保留选中）')

-- nxmap('j', "v:count == 0 ? 'gj' : 'j'", '视觉行向下移动（有计数则跳转物理行）', { expr = true })
-- nxmap('k', "v:count == 0 ? 'gk' : 'k'", '视觉行向上移动（有计数则跳转物理行）', { expr = true })

nmap('<A-k>', '<cmd>m .-2<CR>==', '当前行上移并自动缩进')
nmap('<A-j>', '<cmd>m .+1<CR>==', '当前行下移并自动缩进')
vmap('<A-k>', ":'<,'>move '<-2<CR>gv=gv", '选中行上移')
vmap('<A-j>', ":'<,'>move '>+1<CR>gv=gv", '选中行下移')

-- ==================== tab ====================

nmap('<leader>tn', '<cmd>tabnew<CR>', '新建空白标签页')
nmap('<leader>to', '<C-w>T', '当前窗口独立为新标签页')
nmap('<leader>tc', '<cmd>tabclose<CR>', '关闭当前标签页')

-- ==================== 窗口 ====================

nmap('<leader>wk', '<cmd>resize +10<CR>', '增加窗口高度')
nmap('<leader>wj', '<cmd>resize -10<CR>', '减少窗口高度')
nmap('<leader>wh', '<cmd>vertical resize -10<CR>', '减少窗口宽度')
nmap('<leader>wl', '<cmd>vertical resize +10<CR>', '增加窗口宽度')
nmap('<leader>we', '<cmd>wincmd =<CR>', '所有窗口等分大小')

nmap('<leader>wv', '<C-w>v', '垂直分屏（右侧）')
nmap('<leader>ws', '<C-w>s', '水平分屏（下方）')
nmap('<leader>wd', '<C-w>c', '关闭当前窗口')

nmap('gh', '<C-w>h', '切换到左侧窗口')
nmap('gl', '<C-w>l', '切换到右侧窗口')
nmap('gk', '<C-w>k', '切换到上方窗口')
nmap('gj', '<C-w>j', '切换到下方窗口')

nmap('gwh', '<C-w>H', '移动窗口（到最左侧）')
nmap('gwl', '<C-w>L', '移动窗口（到最右侧）')
nmap('gwk', '<C-w>K', '移动窗口（到最上侧）')
nmap('gwj', '<C-w>J', '移动窗口（到最下侧）')

-- ==================== 缓冲区管理 ====================

nmap('<leader>bb', '<cmd>e #<CR>', '切换到交替缓冲区')
nmap('<leader>bn', '<cmd>bn<CR>', '切换到下一个缓冲区')
nmap('<leader>bp', '<cmd>bp<CR>', '切换到上一个缓冲区')
nmap('<leader>bd', '<cmd>bd<CR>', '删除当前缓冲区')
nmap('<leader>bD', '<cmd>%bd!<CR>', '强制删除当前所有缓冲区')
nmap('<leader>bl', '<cmd>ls<CR>', '查看缓冲区文件')

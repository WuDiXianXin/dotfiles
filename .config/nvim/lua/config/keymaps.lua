-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- 1. 插入模式：kj 快速退出到普通模式
vim.keymap.set('i', 'kj', '<Esc>', {
  noremap = true,
  silent = true,
  desc = '映射返回键，退出插入模式',
})

-- 3. 替换全文内容
vim.keymap.set(
  'n',
  '<leader>cp',
  -- ggVG全选 → "_d删除（不污染寄存器）→ P粘贴剪贴板内容
  ':normal! ggVG"_dP<CR>',
  { noremap = true, silent = true, desc = '替换全文为剪贴板内容' }
)

-- 4. 视觉行导航
vim.keymap.set({ 'n', 'x', 'o' }, 'j', 'gj', { noremap = true, silent = true, desc = '向下导航（视觉行）' })
vim.keymap.set({ 'n', 'x', 'o' }, 'k', 'gk', { noremap = true, silent = true, desc = '向上导航（视觉行）' })
vim.keymap.set(
  { 'n', 'x', 'o' },
  '<Down>',
  'gj',
  { noremap = true, silent = true, desc = '向下导航（视觉行）' }
)
vim.keymap.set({ 'n', 'x', 'o' }, '<Up>', 'gk', { noremap = true, silent = true, desc = '向上导航（视觉行）' })

-- 5. 行移动
vim.keymap.set('n', '<A-k>', ':m-2<CR>', { noremap = true, silent = true, desc = '光标行上移' })
vim.keymap.set('n', '<A-j>', ':m+<CR>', { noremap = true, silent = true, desc = '光标行下移' })
vim.keymap.set('v', '<A-k>', ":m '<-2<CR>gv=gv", { noremap = true, silent = true, desc = '所选多行上移' })
vim.keymap.set('v', '<A-j>', ":m '>+1<CR>gv=gv", { noremap = true, silent = true, desc = '所选多行下移' })

-- 7. 搜索高亮切换
vim.keymap.set('n', '<C-l>', function()
  vim.opt.hlsearch = not vim.opt.hlsearch
  vim.cmd('redraw')
end, { noremap = true, silent = false, desc = '切换搜索高亮显示' })

-- 12 MIniPick
-- 🔍 浏览/打开文件（Pick files）
vim.keymap.set('n', '<leader>ff', ':Pick files<CR>', { noremap = true, silent = true, desc = 'MiniPick: Find files' })

-- 📋 切换/管理已打开的缓冲区（Pick buffers）
vim.keymap.set(
  'n',
  '<leader>fb',
  ':Pick buffers<CR>',
  { noremap = true, silent = true, desc = 'MiniPick: Find buffers' }
)

-- 🔎 实时模糊搜索文本（Pick grep_live）
vim.keymap.set(
  'n',
  '<leader>fg',
  ':Pick grep_live<CR>',
  { noremap = true, silent = true, desc = 'MiniPick: Live grep (real-time)' }
)

-- 🎯 一次性精准搜索文本（Pick grep）
vim.keymap.set('n', '<leader>fG', ':Pick grep<CR>', { noremap = true, silent = true, desc = 'MiniPick: Grep (static)' })

-- ↩️ 恢复上一次 Pick 会话（Pick resume）
vim.keymap.set(
  'n',
  '<leader>fr',
  ':Pick resume<CR>',
  { noremap = true, silent = true, desc = 'MiniPick: Resume last pick session' }
)

-- 📖 搜索 Neovim 帮助文档（Pick help）
vim.keymap.set(
  'n',
  '<leader>fh',
  ':Pick help<CR>',
  { noremap = true, silent = true, desc = 'MiniPick: Search Neovim help docs' }
)

-- 13. 文件
vim.keymap.set('n', '<leader>e', ':lua MiniFiles.open()<CR>', { noremap = true, silent = true, desc = 'Mini-Files' })

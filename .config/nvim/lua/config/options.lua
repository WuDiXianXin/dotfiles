-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
-- ===================== 全局变量 =====================
vim.g.have_nerd_font = true
vim.g.loaded_netrw = 0
vim.g.loaded_netrwPlugin = 0
vim.g.loaded_node_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_perl_provider = 0
-- ===================== 快捷键 =====================
vim.opt.timeoutlen = 500
vim.opt.ttimeoutlen = 500
-- ===================== 文本与缩进 =====================
vim.opt.encoding = 'utf-8'
vim.opt.whichwrap = 'bs<>[]hl' -- 光标跨行移动控制
vim.opt.linebreak = true -- 按照「单词边界」换行
vim.opt.breakat = ' \t;:,!?.' -- 长行折行分隔点控制
vim.opt.scrolloff = 8 -- 上下保留 8 行缓冲
-- ===================== 代码折叠 =====================
vim.opt.foldmethod = 'expr'
vim.opt.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
-- ===================== 窗口 =====================
vim.opt.mouse = 'a' -- 全模式启动鼠标
vim.opt.laststatus = 3 -- 全局统一状态栏
vim.opt.winborder = 'rounded' -- 窗口边框样式
-- ===================== 空白字符显示 =====================
vim.opt.list = true
vim.opt.listchars = {
  tab = '» ', -- Tab 显示为 » + 空格
  trail = '·', -- 行尾空格显示为 ·
  nbsp = '␣', -- 非断行空格（比如全角空格、&nbsp;）
  -- multispace = '·', -- 突出连续空格（代替space）
  space = ' ', -- 普通空格不显示（仅行尾显示）
  extends = '>', -- 行宽超出显示 >
  precedes = '<', -- 行首截断显示 <
}

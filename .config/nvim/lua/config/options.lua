-- ===================== 全局变量 =====================

vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

vim.g.have_nerd_font = true

vim.g.loaded_netrw = 0
vim.g.loaded_netrwPlugin = 0

vim.g.loaded_node_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_perl_provider = 0

vim.g.bigfile_size = 1024 * 1024 * 2

-- ===================== 基础渲染 =====================

vim.opt.termguicolors = true -- 开启真彩色，保证颜色/透明正常
vim.opt.background = 'dark' -- 适配深色终端

-- ===================== 剪贴板 =====================

vim.opt.clipboard:append('unnamedplus') -- 需要安装 wl-clipboard

-- ===================== 行号与光标 =====================

vim.opt.number = true -- 显示绝对行号
vim.opt.relativenumber = true -- 显示相对行号
vim.opt.signcolumn = 'yes' -- 始终显示符号列
vim.opt.cursorline = true -- 高亮光标行
-- vim.opt.cursorcolumn = true
vim.opt.scrolloff = 4 -- 垂直保留 4 行缓冲

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

-- ===================== 搜索配置 =====================

vim.opt.ignorecase = true -- 忽略大小写
vim.opt.smartcase = true -- 输入大写时精准匹配
vim.opt.hlsearch = true -- 搜索结果高亮
vim.opt.incsearch = true -- 增量搜索（实时匹配）
vim.opt.inccommand = 'split' -- 预览替换效果

-- ===================== 文本与缩进 =====================

-- vim.opt.cc = '80'
vim.opt.encoding = 'utf-8'
vim.opt.whichwrap = 'bs<>[]hl' -- 光标跨行移动控制
-- vim.opt.wrap = true            -- 开启文本换行
vim.opt.linebreak = true -- 按照「单词边界」换行
vim.opt.breakat = ' \t;:,!?.' -- 长行折行分隔点控制
vim.opt.breakindent = true -- 折行保持缩进
vim.opt.autoindent = true -- 新建行自动缩进
vim.opt.expandtab = true -- 将 tab 转为空格
vim.opt.tabstop = 2 -- 一个 tab 对应 2 个空格
vim.opt.softtabstop = 2 -- 编辑模式下 tab 键的空格数
vim.opt.shiftwidth = 2 -- 缩进/取消缩进的空格数
vim.opt.undofile = true -- 持久化撤销历史
vim.opt.updatetime = 250 -- 自动触发时间频率

-- ===================== 代码折叠 =====================

vim.opt.foldenable = true -- 启用折叠（关闭则用 zA 等命令也无法折叠）
vim.opt.foldmethod = 'expr'
vim.opt.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
vim.opt.foldlevel = 99 -- 默认不折叠
vim.opt.foldlevelstart = 99
vim.opt.foldminlines = 1 -- 新增：避免空折叠

function _G.custom_foldtext()
  -- 1. 获取折叠起始行文本（替换制表符）
  local start_text = vim.fn.getline(vim.v.foldstart):gsub('\t', string.rep(' ', vim.o.tabstop))
  -- 2. 计算折叠行数
  local nline = vim.v.foldend - vim.v.foldstart
  -- 3. 折叠图标（折叠显示，展开无）
  local fold_closed = vim.fn.foldclosed(vim.v.foldstart)
  local fold_icon = fold_closed > 0 and '▶ ' or ''

  -- 4. 直接返回带基础高亮的文本（复用行的默认高亮）
  return table.concat({
    fold_icon,
    start_text,
    '  󰛁  ',
    nline,
    ' lines folded',
  })
end

vim.opt.foldtext = 'v:lua.custom_foldtext()'

-- ===================== 窗口 =====================

vim.opt.mouse = 'a' -- 全模式启动鼠标
vim.opt.laststatus = 3 -- 全局统一状态栏
vim.opt.winborder = 'rounded' -- 窗口边框样式

vim.opt.splitright = true -- 新窗口默认右侧分割
vim.opt.splitbelow = true -- 新窗口默认下方分割

-- 挪移至mini.icons中
-- vim.diagnostic.config({
--   signs = {
--     -- 核心：text 字段映射“诊断级别→图标”
--     text = {
--       -- [vim.diagnostic.severity.ERROR] = ' ', -- 错误图标
--       -- [vim.diagnostic.severity.WARN] = ' ', -- 警告图标
--       -- [vim.diagnostic.severity.INFO] = '󰋼 ', -- 信息图标
--       -- [vim.diagnostic.severity.HINT] = ' ', -- 提示图标
--       [vim.diagnostic.severity.ERROR] = require('mini.icons').get('lsp', 'Error')[1] .. ' ',
--       [vim.diagnostic.severity.WARN] = require('mini.icons').get('lsp', 'Warning')[1] .. ' ',
--       [vim.diagnostic.severity.INFO] = require('mini.icons').get('lsp', 'Information')[1] .. ' ',
--       [vim.diagnostic.severity.HINT] = require('mini.icons').get('lsp', 'Hint')[1] .. ' ',
--     },
--     severity = { min = vim.diagnostic.severity.HINT }, -- 显示所有级别（默认）
--   },
--   float = {
--     border = 'rounded',
--     source = 'if_many',
--   },
--   virtual_lines = {
--     current_line = true, -- 虚行显示 lsp 提示
--   },
-- })

-- ===================== 底部栏 =====================

vim.opt.showmode = false

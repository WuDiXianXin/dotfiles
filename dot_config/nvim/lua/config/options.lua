-- ===================== 全局变量 =====================

local g = vim.g
local opt = vim.opt

g.transparent = true

g.mapleader = ' '
g.maplocalleader = ' '

g.have_nerd_font = true

g.loaded_netrw = 0
g.loaded_netrwPlugin = 0

g.loaded_node_provider = 0
g.loaded_ruby_provider = 0
g.loaded_perl_provider = 0
g.loaded_python3_provider = 0

-- ===================== 基础渲染 =====================

opt.termguicolors = true -- 开启真彩色，保证颜色/透明正常
opt.background = 'dark' -- 适配深色终端
-- 延迟重绘，减少渲染压力，
-- 缺点：搜索内容时会导致固定序列，无法确定第几个结果
-- opt.lazyredraw = true
opt.synmaxcol = 500 -- 限制语法高亮列数，提高性能

-- ===================== 行号与光标 =====================

opt.number = true -- 显示绝对行号
opt.relativenumber = true -- 显示相对行号
opt.signcolumn = 'yes' -- 始终显示符号列
opt.cursorline = true -- 高亮光标行
-- opt.cursorcolumn = true -- 高亮光标列
opt.scrolloff = 8 -- 垂直保留 8 行缓冲

-- ===================== 空白字符显示 =====================

opt.list = true
opt.listchars = {
    tab = '» ', -- Tab 显示为 » + 空格
    trail = '·', -- 行尾空格显示为 ·
    nbsp = '␣', -- 非断行空格（比如全角空格、&nbsp;）
    -- multispace = '·', -- 突出连续空格（代替space）
    space = ' ', -- 普通空格不显示（仅行尾显示）
    extends = '>', -- 行宽超出显示 >
    precedes = '<', -- 行首截断显示 <
}

-- ===================== 搜索配置 =====================

opt.ignorecase = true -- 忽略大小写
opt.smartcase = true -- 输入大写时精准匹配
opt.hlsearch = true -- 搜索结果高亮
opt.incsearch = true -- 增量搜索（实时匹配）
opt.inccommand = 'split' -- 预览替换效果

-- ===================== 文本与缩进 =====================

-- opt.cc = '80'
-- opt.colorcolumn = '120'
opt.clipboard = 'unnamedplus' -- 寄存器 "+ 与系统剪切板互通
vim.scriptencoding = 'utf-8' -- 脚本编码为 UTF-8
opt.encoding = 'utf-8' -- 内部编码为 UTF-8
opt.fileencoding = 'utf-8' -- 文件编码为 UTF-8
opt.whichwrap = 'bs<>[]hl' -- 光标跨行移动控制
opt.wrap = false -- 关闭文本换行
opt.linebreak = true -- 按照「单词边界」换行
opt.breakat = ' \t;:,!?.' -- 长行折行分隔点控制
opt.breakindent = true -- 折行保持缩进
opt.autoindent = true -- 新建行自动缩进
opt.expandtab = true -- 将 tab 转为空格
opt.tabstop = 4 -- 一个 tab 对应 4 个空格
opt.softtabstop = 4 -- 编辑模式下 tab 键的空格数
opt.shiftwidth = 4 -- 缩进/取消缩进的空格数
opt.undofile = false -- 持久化撤销历史
opt.swapfile = false -- 保存前临时复制一份
opt.backup = false
opt.writebackup = false
opt.updatetime = 250 -- 自动触发时间频率

-- ===================== 文件对比 =====================

opt.diffopt = {
    'internal', -- 使用内置 diff 算法
    'filler', -- 显示填充行
    'closeoff', -- 自动关闭只剩一个 diff 窗口时退出 diff 模式
    'indent-heuristic', -- 更好的缩进识别
    'inline:char', -- 行内字符级高亮（非常推荐）
    'linematch:150', -- 更好的 hunk 对齐
    'algorithm:histogram', -- histogram 对代码友好
    -- 'context:9999', -- 你想要的上下文行数
}

-- ===================== 代码折叠 =====================

opt.foldenable = true -- 启用折叠（关闭则用 zA 等命令也无法折叠）
opt.foldmethod = 'expr'
opt.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
opt.foldlevel = 99 -- 默认不折叠
opt.foldlevelstart = 99
opt.foldminlines = 1 -- 避免空折叠

-- 自定义折叠样式
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

opt.mouse = 'a' -- 全模式启动鼠标
-- opt.laststatus = 3 -- 全局统一状态栏
opt.winborder = 'rounded' -- 窗口边框样式

-- opt.winbar = '%f %m'

-- opt.cmdheight = 0

opt.splitright = true -- 新窗口默认右侧分割
opt.splitbelow = true -- 新窗口默认下方分割

-- ===================== 底部栏 =====================

opt.showmode = false

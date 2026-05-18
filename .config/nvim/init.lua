vim.loader.enable()

-- 加载基础配置
require('config.options')
require('config.autocmds')
require('config.keymaps')
require('config.lsp')

-- 外观 && mini
require('plugins.colortheme')
require('plugins.mini')
require('plugins.lualine')
require('plugins.gitsigns')

-- dap 调试
require('plugins.dap')

-- 语言
require('plugins.rust')

-- Markveiw
require('plugins.markview')

-- 大纲
require('plugins.outline')

-- cmp
require('plugins.cmp')

-- ai
-- require('plugins.neocodeium')

-- 按键提示
require('plugins.which-key')

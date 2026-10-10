-- 加速 Neovim 的 Lua 模块的加载
vim.loader.enable(true)

-- 加载基础配置
require('config.options')
require('config.keymaps')
require('config.autocmds')

-- 启动 UI2
require('vim._core.ui2').enable({
    enable = true,
    msg = {
        targets = 'msg',
    },
})

-- LSP 配置（必须先加载）
require('config.lsp')

require('config.lazy')

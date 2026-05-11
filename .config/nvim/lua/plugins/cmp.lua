vim.pack.add({
    {
        src = 'https://github.com/xzbdmw/colorful-menu.nvim',
        branch = 'master',
    },
    {
        src = 'https://github.com/saghen/blink.lib',
        branch = 'main',
    },
    {
        src = 'https://github.com/saghen/blink.cmp',
        branch = 'main',
    },
})

require('blink.cmp').build():wait(60000)

require('blink.cmp').setup({
    keymap = {
        preset = 'none',

        -- Ctrl+空格：只显示代码片段补全
        ['<C-space>'] = {
            function(cmp)
                cmp.show({ providers = { 'lsp' } })
            end,
        },

        -- 上下键选择补全项
        ['<Up>'] = { 'select_prev', 'fallback' },
        ['<Down>'] = { 'select_next', 'fallback' },

        -- Ctrl+n/Ctrl+p：选择下/上一个补全项（符合通用习惯）
        ['<C-n>'] = { 'select_next', 'fallback' },
        ['<C-p>'] = { 'select_prev', 'fallback' },

        -- ESC键 - 优先隐藏补全菜单，无补全则执行默认ESC行为（推荐）
        ['<Esc>'] = { 'hide', 'fallback' },

        -- Ctrl+e - 彻底取消补全（回滚内容+隐藏菜单）
        ['<C-e>'] = { 'cancel' },

        -- 确认候选项
        ['<C-y>'] = { 'accept' },
    },

    cmdline = {
        enabled = true,
        completion = { menu = { auto_show = true } },
    },

    appearance = {
        nerd_font_variant = 'mono',
    },

    completion = {
        documentation = { auto_show = true },
        menu = {
            draw = {
                columns = { { 'kind_icon' }, { 'label', gap = 1 } },
                components = {
                    label = {
                        text = function(ctx)
                            return require('colorful-menu').blink_components_text(ctx)
                        end,
                        highlight = function(ctx)
                            return require('colorful-menu').blink_components_highlight(ctx)
                        end,
                    },
                },
            },
        },
    },

    signature = { enabled = true },

    sources = {
        -- default = { 'path', 'lsp', 'buffer', 'avante' },
        default = { 'path', 'lsp', 'buffer' },
        providers = {
            buffer = { enabled = true, max_items = 6 },
            -- snippets = { score_offset = 99 },
            -- avante = {
            --     module = 'blink-cmp-avante',
            --     name = 'Avante',
            -- },
        },
    },

    -- -- 新增：动态添加 crates 来源（仅当 crates.nvim 已加载时）
    -- setup = function()
    --   local cmp = require('blink.cmp')
    --   -- 检查 crates.nvim 是否已加载（通过 pcall 安全检测）
    --   local ok, crates = pcall(require, 'crates')
    --   if ok then
    --     cmp.register_source('crates', crates.cmp_source())
    --   end
    -- end,

    fuzzy = {
        implementation = 'prefer_rust_with_warning',
    },

    -- snippets = {
    --     preset = 'luasnip',
    -- },
})

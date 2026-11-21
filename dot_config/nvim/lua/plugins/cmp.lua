-- Blink 补全
return {
    {
        'saghen/blink.cmp',
        event = 'UIEnter',
        dependencies = {
            -- Blink 补全核心库
            'saghen/blink.lib',
            -- Blink 补全美化菜单
            'xzbdmw/colorful-menu.nvim',
            -- Snippets 源
            'rafamadriz/friendly-snippets',
        },
        config = function()
            require('blink.cmp').build():pwait(120000)

            require('blink.cmp').setup({
                -- 仅 i 模式 键盘映射
                keymap = {
                    -- 不使用预设
                    preset = 'none',

                    -- Ctrl+空格：只显示 snippets 补全
                    ['<C-space>'] = {
                        function(cmp)
                            cmp.show({ providers = { 'snippets' } })
                        end,
                    },

                    -- 前后进行 snippets 选择
                    ['<Tab>'] = { 'snippet_forward', 'fallback' },
                    ['<S-Tab>'] = { 'snippet_backward', 'fallback' },

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
                    documentation = {
                        auto_show = true,
                    },
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
                    default = { 'path', 'lsp', 'snippets', 'buffer' },
                    providers = {
                        buffer = { enabled = true, max_items = 6 },
                        -- snippets = { score_offset = 99 },
                    },
                },

                snippets = { preset = 'default' },

                fuzzy = { implementation = 'rust' },
            })
        end,
    },
}

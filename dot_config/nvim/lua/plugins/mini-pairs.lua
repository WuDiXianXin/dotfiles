-- 自动括号
return {
    {
        'nvim-mini/mini.pairs',
        event = 'InsertEnter',
        config = function()
            require('mini.pairs').setup({
                mappings = {
                    -- <>：按<自动补>并跳到中间
                    ['<lt>'] = { action = 'open', pair = '<>', neigh_pattern = '[^\\].' },
                    ['>'] = { action = 'close', pair = '<>', neigh_pattern = '[^\\].' },

                    -- 《》
                    ['《'] = { action = 'open', pair = '《》', neigh_pattern = '[^\\].' },
                    ['》'] = { action = 'close', pair = '《》', neigh_pattern = '[^\\].' },

                    -- 「」
                    ['「'] = { action = 'open', pair = '「」', neigh_pattern = '[^\\].' },
                    ['」'] = { action = 'close', pair = '「」', neigh_pattern = '[^\\].' },

                    -- 【】
                    ['【'] = { action = 'open', pair = '【】', neigh_pattern = '[^\\].' },
                    ['】'] = { action = 'close', pair = '【】', neigh_pattern = '[^\\].' },

                    -- ‘’
                    ['‘'] = { action = 'open', pair = '‘’', neigh_pattern = '[^\\].' },
                    ['’'] = { action = 'close', pair = '‘’', neigh_pattern = '[^\\].' },

                    -- “”
                    ['“'] = { action = 'open', pair = '“”', neigh_pattern = '[^\\].' },
                    ['”'] = { action = 'close', pair = '“”', neigh_pattern = '[^\\].' },
                },
            })
        end,
    },
}

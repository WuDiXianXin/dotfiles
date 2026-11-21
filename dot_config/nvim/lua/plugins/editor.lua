return {
    {
        'stevearc/conform.nvim',
        event = { 'BufWritePre' },
        cmd = { 'ConformInfo' },
        opts = {
            formatters_by_ft = {
                rust = { 'rustfmt' },
                lua = { 'stylua' },
                toml = { 'taplo' },
            },
            format_on_save = function(bufnr)
                if vim.b[bufnr].large_file then
                    return
                end
                return { timeout_ms = 1000, lsp_format = 'fallback' }
            end,
        },
    },
    {
        -- 高亮模式 (如 TODO、颜色等)
        'nvim-mini/mini.hipatterns',
        event = 'BufReadPost',
        config = function()
            require('mini.hipatterns').setup({
                highlighters = {
                    -- 经典四件套
                    fixme = { pattern = '%f[%w]()FIXME()%f[%W]', group = 'MiniHipatternsFixme' },
                    hack = { pattern = '%f[%w]()HACK()%f[%W]', group = 'MiniHipatternsHack' },
                    todo = { pattern = '%f[%w]()TODO()%f[%W]', group = 'MiniHipatternsTodo' },
                    note = { pattern = '%f[%w]()NOTE()%f[%W]', group = 'MiniHipatternsNote' },

                    -- 十六进制颜色
                    hex_color = require('mini.hipatterns').gen_highlighter.hex_color(),

                    -- 日志级别
                    log_error_multi = { pattern = { '%[ERROR%]', 'ERROR:', 'ERROR%s*-' }, group = 'DiagnosticError' },
                    log_warn_multi = { pattern = { '%[WARN%]', 'WARN:', 'WARN%s*-' }, group = 'DiagnosticWarn' },
                    log_info_multi = { pattern = { '%[INFO%]', 'INFO:', 'INFO%s*-' }, group = 'DiagnosticInfo' },
                    log_debug_multi = { pattern = { '%[DEBUG%]', 'DEBUG:', 'DEBUG%s*-' }, group = 'DiagnosticHint' },
                },

                delay = { text_change = 50, scroll = 25 },
            })
        end,
    },
    {
        -- 文本对象增强 (ai)
        'nvim-mini/mini.ai',
        event = 'VeryLazy',
        config = function()
            local ai = require('mini.ai')

            ai.setup({
                n_lines = 500,
                search_method = 'cover_or_next',

                custom_textobjects = {
                    ['<'] = ai.gen_spec.pair('<', '>'),
                    ['《'] = ai.gen_spec.pair('《', '》'),
                    ['「'] = ai.gen_spec.pair('「', '」'),
                    ['【'] = ai.gen_spec.pair('【', '】'),
                    ['‘'] = ai.gen_spec.pair('‘', '’'),
                    ['“'] = ai.gen_spec.pair('“', '”'),
                    ['（'] = ai.gen_spec.pair('（', '）'),
                },
            })
        end,
    },
    {
        -- 自动括号
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

                    -- （）
                    ['（'] = { action = 'open', pair = '（）', neigh_pattern = '[^\\].' },
                    ['）'] = { action = 'close', pair = '（）', neigh_pattern = '[^\\].' },
                },
            })
        end,
    },
    {
        -- 环绕编辑 (surround)
        'nvim-mini/mini.surround',
        event = 'VeryLazy',
        config = function()
            require('mini.surround').setup({
                custom_surroundings = {
                    ['<'] = {
                        input = { '<().-()>' },
                        output = { left = '<', right = '>' },
                    },
                    ['《'] = {
                        input = { '《().-()》' },
                        output = { left = '《', right = '》' },
                    },
                    ['「'] = {
                        input = { '「().-()」' },
                        output = { left = '「', right = '」' },
                    },
                    ['【'] = {
                        input = { '【().-()】' },
                        output = { left = '【', right = '】' },
                    },
                    ['‘'] = {
                        input = { '‘().-()’' },
                        output = { left = '‘', right = '’' },
                    },
                    ['“'] = {
                        input = { '“().-()”' },
                        output = { left = '“', right = '”' },
                    },
                    ['（'] = {
                        input = { '（().-()）' },
                        output = { left = '（', right = '）' },
                    },
                },
            })
        end,
    },
}

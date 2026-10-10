-- 高亮模式 (如 TODO、颜色等)
return {
    {
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
}

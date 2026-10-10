-- 文本对象增强 (ai)
return {
    {
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
                },
            })
        end,
    },
}

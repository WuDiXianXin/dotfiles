-- 环绕编辑 (surround)
return {
    {
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
                },
            })
        end,
    },
}

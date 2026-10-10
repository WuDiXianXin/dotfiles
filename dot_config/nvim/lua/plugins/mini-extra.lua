-- 额外工具集
return {
    {
        'nvim-mini/mini.extra',
        event = 'VeryLazy',
        config = function()
            require('mini.extra').setup()
        end,
    },
}

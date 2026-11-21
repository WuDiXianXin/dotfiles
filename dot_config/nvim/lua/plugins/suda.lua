return {
    {
        'WuDiXianXin/suda.nvim',
        config = function()
            require('suda').setup({
                -- smart_edit = true,
                debug = true,
            })
        end,
    },
}

-- 缩进范围显示
return {
    'saghen/blink.indent',
    event = 'BufReadPost',
    config = function()
        require('blink.indent').setup({
            scope = {
                highlights = { 'BlinkIndentGreen' },
            },
        })
    end,
}

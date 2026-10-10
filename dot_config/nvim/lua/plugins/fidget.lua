-- LSP 加载状态通知
return {
    {
        'j-hui/fidget.nvim',
        event = 'LspAttach',
        config = function()
            require('fidget').setup()
        end,
    },
}

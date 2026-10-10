-- 文件浏览器
return {
    {
        'nvim-mini/mini.files',
        keys = {
            { '<leader>e', mode = 'n' },
            { '<leader>E', mode = 'n' },
        },
        config = function()
            require('mini.files').setup({
                windows = {
                    preview = true,
                    width_focus = 25,
                    width_preview = 80,
                },
            })
            local nmap = require('utils.keymap').nmap
            nmap('<leader>e', '<cmd>lua MiniFiles.open()<CR>', '打开文件管理器')
            nmap('<leader>E', '<cmd>lua MiniFiles.open(vim.api.nvim_buf_get_name(0))<CR>', '打开文件管理器')
        end,
    },
}

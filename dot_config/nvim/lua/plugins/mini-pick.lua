-- 选择器 (picker)
return {
    {
        'nvim-mini/mini.pick',
        event = 'UIEnter',
        -- keys = {
        --     { '<leader>f', mode = 'n' },
        -- },
        config = function()
            require('mini.pick').setup()
            local nmap = require('utils.keymap').nmap
            nmap('<leader>ff', '<cmd>Pick files<CR>', '查找文件')
            nmap('<leader>fb', '<cmd>Pick buffers<CR>', '查找缓冲区')
            nmap('<leader>fg', '<cmd>Pick grep_live<CR>', '实时文本搜索')
            nmap('<leader>fG', '<cmd>Pick grep<CR>', '静态文本搜索')
            nmap('<leader>fr', '<cmd>Pick resume<CR>', '恢复上次查找')
            nmap('<leader>fh', '<cmd>Pick help<CR>', '搜索帮助文档')

            require('which-key').add({
                { '<leader>f', group = '查找' },
            })
        end,
    },
}

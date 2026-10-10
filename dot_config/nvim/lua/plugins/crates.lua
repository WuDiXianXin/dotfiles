-- Crates.toml 版本管理
return {
    {
        'saecki/crates.nvim',
        event = 'BufRead Cargo.toml',
        config = function()
            local crates = require('crates')
            crates.setup({
                autoload = true,
                autoupdate = true,
                loading_indicator = true,
                lsp = {
                    enabled = true,
                    actions = true,
                    completion = true,
                    hover = true,
                },
            })
            local nmap = require('utils.keymap').nmap
            nmap('<leader>cu', crates.upgrade_all_crates, 'Crates: 升级所有依赖')
            nmap('<leader>cU', crates.update_all_crates, 'Crates: 更新所有依赖')
            nmap('<leader>ch', crates.show_popup, 'Crates: 显示版本/特性弹窗')
            nmap('<leader>cv', crates.show_versions_popup, 'Crates: 显示版本弹窗')
            nmap('<leader>cf', crates.show_features_popup, 'Crates: 显示特性弹窗')
            nmap('<leader>cd', crates.open_documentation, 'Crates: 打开文档')
            nmap('<leader>cr', crates.reload, 'Crates: 重新加载缓存')

            require('which-key').add({
                { '<leader>c', group = 'Crates/Cargo' },
            })
        end,
    },
}

vim.pack.add({
    {
        src = 'https://github.com/mrcjkb/rustaceanvim',
        branch = 'main',
    },
    {
        src = 'https://github.com/nvim-lua/plenary.nvim',
        branch = 'master',
    },
    {
        src = 'https://github.com/saecki/crates.nvim',
        branch = 'main',
    },
})

require('crates').setup({
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

local crates = require('crates')
vim.keymap.set('n', '<leader>cu', crates.upgrade_all_crates, { desc = 'Crates: 升级所有依赖' })
vim.keymap.set('n', '<leader>cU', crates.update_all_crates, { desc = 'Crates: 更新所有依赖' })
vim.keymap.set('n', '<leader>ch', crates.show_popup, { desc = 'Crates: 显示版本/特性弹窗' })
vim.keymap.set('n', '<leader>cv', crates.show_versions_popup, { desc = 'Crates: 显示版本弹窗' })
vim.keymap.set('n', '<leader>cf', crates.show_features_popup, { desc = 'Crates: 显示特性弹窗' })
vim.keymap.set('n', '<leader>cd', crates.open_documentation, { desc = 'Crates: 打开文档' })
vim.keymap.set('n', '<leader>cr', crates.reload, { desc = 'Crates: 重新加载缓存' })

-- Rustaceanvim 配置...
vim.g.rustaceanvim = function()
    -- Update this path
    local extension_path = vim.env.HOME .. '/.config/nvim/tools/codelldb/extension/'
    local codelldb_path = extension_path .. 'adapter/codelldb'
    local liblldb_path = extension_path .. 'lldb/lib/liblldb'
    local this_os = vim.uv.os_uname().sysname

    -- The path is different on Windows
    if this_os:find('Windows') then
        codelldb_path = extension_path .. 'adapter\\codelldb.exe'
        liblldb_path = extension_path .. 'lldb\\bin\\liblldb.dll'
    else
        -- The liblldb extension is .so for Linux and .dylib for MacOS
        liblldb_path = liblldb_path .. (this_os == 'Linux' and '.so' or '.dylib')
    end

    local cfg = require('rustaceanvim.config')
    return {
        server = {
            cmd = { 'rust-analyzer' },

            default_settings = {
                ['rust-analyzer'] = {
                    check = { command = 'clippy' },
                    cargo = { allFeatures = true },
                    inlayHints = {
                        bindingModeHints = { enable = true },
                        closureReturnTypeHints = { enable = 'always' },
                        lifetimeElisionHints = { enable = 'always' },
                    },
                },
            },
        },
        dap = {
            adapter = cfg.get_codelldb_adapter(codelldb_path, liblldb_path),
        },
    }
end

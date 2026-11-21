return {
    {
        'mrcjkb/rustaceanvim',
        config = function()
            -- Rustaceanvim 配置
            vim.g.rustaceanvim = function()
                local codelldb_pkg = require('mason-registry').get_package('codelldb')
                local install_root = codelldb_pkg:get_install_path()
                local codelldb_path = install_root .. '/extension/adapter/codelldb'
                -- local liblldb_path = install_root .. '/extension/lldb/lib/liblldb.so'

                local liblldb_path = install_root .. '/extension/lldb/lib/liblldb'
                local this_os = vim.uv.os_uname().sysname

                -- The path is different on Windows
                if this_os:find('Windows') then
                    codelldb_path = install_root .. '\\extension\\adapter\\codelldb.exe'
                    liblldb_path = install_root .. '\\extension\\lldb\\bin\\liblldb.dll'
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
                                -- check = { command = 'clippy' },
                                check = { command = 'check' },
                                cargo = { allFeatures = true },
                                semanticHighlighting = { enable = false },
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
        end,
    },
    {
        -- Crates.toml 版本管理
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

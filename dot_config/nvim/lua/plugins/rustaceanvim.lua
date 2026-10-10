return {
    {
        'mrcjkb/rustaceanvim',
        lazy = false,
        config = function()
            -- Rustaceanvim 配置
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
}

return {
    {
        'igorlfs/nvim-dap-view',
        keys = {
            { '<F9>', mode = 'n' }, -- 切换断点（最常用）
            { '<leader>d', mode = 'n' }, -- 切换断点
        },
        dependencies = {
            'mfussenegger/nvim-dap',
        },
        config = function()
            require('dap-view').setup({
                winbar = {
                    show_keymap_hints = false,
                    sections = {
                        'watches',
                        'scopes',
                        'exceptions',
                        'repl',
                        'sessions',
                        'breakpoints',
                        'threads',
                        'console',
                    },
                    default_section = 'console',
                    controls = {
                        enabled = true,
                        position = 'left',
                    },
                },
                switchbuf = 'usetab,newtab',
                windows = {
                    size = 0.6,
                    position = 'right',
                    terminal = {
                        size = 0.5,
                        position = 'right',
                    },
                },
            })
        end,
    },
    {
        'mfussenegger/nvim-dap',
        lazy = true,
        config = function()
            -- ==================== 主题颜色（tokyonight） ====================
            local colors = require('tokyonight.colors').setup()

            -- ==================== 调试标记高亮组（先定义，供符号引用） ====================
            vim.api.nvim_set_hl(0, 'DapBreakpoint', { fg = colors.red, bold = true })
            vim.api.nvim_set_hl(0, 'DapBreakpointCondition', { fg = colors.orange, bold = true })
            vim.api.nvim_set_hl(0, 'DapStopped', { fg = colors.green, bg = colors.bg_highlight, bold = true })
            vim.api.nvim_set_hl(0, 'DapLogPoint', { fg = colors.blue, bold = true })
            vim.api.nvim_set_hl(0, 'DapBreakpointRejected', { fg = colors.dark5, bold = true })

            -- ==================== 调试标记符号定义（Neovim 0.12 推荐 API） ====================
            local signs = {
                { name = 'DapBreakpoint', text = '●', hl = 'DapBreakpoint', priority = 10 },
                { name = 'DapBreakpointCondition', text = '◆', hl = 'DapBreakpointCondition', priority = 10 },
                { name = 'DapStopped', text = '➜', hl = 'DapStopped', linehl = 'CursorLine', priority = 30 },
                { name = 'DapLogPoint', text = '◇', hl = 'DapLogPoint', priority = 10 },
                { name = 'DapBreakpointRejected', text = '✖', hl = 'DapBreakpointRejected', priority = 10 },
            }

            for _, sign in ipairs(signs) do
                local opts = {
                    text = sign.text,
                    texthl = sign.hl,
                    numhl = sign.hl,
                    priority = sign.priority or 10,
                }
                if sign.linehl then
                    opts.linehl = sign.linehl
                end
                vim.fn.sign_define(sign.name, opts)
            end

            -- ==================== LLDB (codelldb) 适配器 ====================

            local dap = require('dap')

            local codelldb_pkg = require('mason-registry').get_package('codelldb')
            local install_root = codelldb_pkg:get_install_path()
            local codelldb_path = install_root .. '/extension/adapter/codelldb'

            local this_os = vim.uv.os_uname().sysname
            if this_os:find('Windows') then
                codelldb_path = install_root .. '\\extension\\adapter\\codelldb.exe'
            end

            dap.adapters.lldb = {
                type = 'server',
                port = '${port}',
                executable = {
                    command = codelldb_path,
                    args = { '--port', '${port}' },
                },
            }

            -- ==================== C / C++ ====================
            local lldb_launch = {
                name = 'Launch',
                type = 'lldb',
                request = 'launch',
                program = function()
                    local cwd = vim.fn.getcwd()
                    local sep = vim.uv.os_uname().sysname:find('Windows') and '\\' or '/'
                    local default = vim.fs.normalize(cwd) .. sep
                    return vim.fn.input('可执行文件路径: ', default, 'file')
                end,
                cwd = vim.fn.getcwd(),
                stopOnEntry = false,
                args = {},
            }
            dap.configurations.c = { lldb_launch }
            dap.configurations.cpp = { lldb_launch }

            -- ==================== DAP 快捷键绑定 ====================

            local nmap = require('utils.keymap').nmap
            -- F 键系列（标准调试快捷键）
            nmap('<F5>', dap.continue, 'DAP: 继续执行 / 开始调试')
            nmap('<F9>', dap.toggle_breakpoint, 'DAP: 切换断点')
            nmap('<F10>', dap.step_over, 'DAP: 步过')
            nmap('<F11>', dap.step_into, 'DAP: 步入')
            nmap('<F12>', dap.step_out, 'DAP: 步出')

            -- Leader 前缀系列
            nmap('<leader>dc', dap.continue, 'DAP: 继续执行 / 开始调试')
            nmap('<leader>dr', dap.run_last, 'DAP: 重新运行上次调试')
            nmap('<leader>dt', dap.terminate, 'DAP: 终止调试')

            nmap('<leader>dO', dap.step_over, 'DAP: 步过')
            nmap('<leader>di', dap.step_into, 'DAP: 步入')
            nmap('<leader>do', dap.step_out, 'DAP: 步出')

            nmap('<leader>db', dap.toggle_breakpoint, 'DAP: 切换断点')
            nmap('<leader>dB', function()
                dap.set_breakpoint(vim.fn.input('断点条件: '))
            end, 'DAP: 当前行条件断点')
            nmap('<leader>dl', function()
                dap.set_breakpoint(nil, nil, vim.fn.input('日志信息: '))
            end, 'DAP: 日志断点')

            -- nmap('<leader>du', dapui.toggle, 'DAP: 切换调试界面')
            nmap('<leader>du', '<cmd>DapViewToggle<CR>', 'DAP: 切换调试界面')

            -- 清空所有断点
            nmap('<leader>dX', dap.clear_breakpoints, 'DAP: 清空所有断点')

            require('which-key').add({
                { '<leader>d', group = '调试 DAP' },
            })
        end,
    },
}

return {
    {
        'mfussenegger/nvim-dap',
        keys = {
            { '<F9>', mode = 'n' }, -- 切换断点（最常用）
            { '<leader>d', mode = 'n' }, -- 切换断点
        },
        dependencies = {
            'igorlfs/nvim-dap-view',
        },
        config = function()
            -- ==================== 主题颜色（tokyonight） ====================

            local colors = require('tokyonight.colors').setup()

            -- ==================== 调试标记符号及高亮 ====================
            local signs = {
                { name = 'DapBreakpoint', text = '●', hl = 'DapBreakpoint' },
                {
                    name = 'DapBreakpointCondition',
                    text = '◆',
                    hl = 'DapBreakpointCondition',
                },
                {
                    name = 'DapStopped',
                    text = '➜',
                    hl = 'DapStopped',
                    linehl = 'CursorLine',
                },
                { name = 'DapLogPoint', text = '◇', hl = 'DapLogPoint' },
                {
                    name = 'DapBreakpointRejected',
                    text = '⊗',
                    hl = 'DapBreakpointRejected',
                },
            }
            for _, sign in ipairs(signs) do
                vim.fn.sign_define(sign.name, {
                    text = sign.text,
                    texthl = sign.hl,
                    linehl = sign.linehl or '',
                    numhl = sign.hl,
                })
            end

            -- 与 tokyonight 主题完美匹配的高亮
            vim.api.nvim_set_hl(0, 'DapBreakpoint', { fg = colors.red, bold = true })
            vim.api.nvim_set_hl(0, 'DapBreakpointCondition', { fg = colors.orange, bold = true })
            vim.api.nvim_set_hl(0, 'DapStopped', { fg = colors.green, bg = colors.bg_highlight, bold = true })
            vim.api.nvim_set_hl(0, 'DapLogPoint', { fg = colors.blue, bold = true })
            vim.api.nvim_set_hl(0, 'DapBreakpointRejected', { fg = colors.dark5, bold = true })

            -- ==================== LLDB (codelldb) 适配器 ====================

            local dap = require('dap')

            dap.adapters.lldb = {
                type = 'executable',
                command = vim.fn.expand('~/.config/nvim/tools/codelldb/extension/adapter/codelldb'),
                name = 'lldb',
            }

            -- ==================== C / C++ ====================

            local lldb_launch = {
                name = 'Launch',
                type = 'lldb',
                request = 'launch',
                program = function()
                    return vim.fn.input('可执行文件路径: ', vim.fn.getcwd() .. '/', 'file')
                end,
                cwd = '${workspaceFolder}',
                stopOnEntry = false,
                args = {},
            }
            dap.configurations.c = { lldb_launch }
            dap.configurations.cpp = { lldb_launch }

            -- ==================== DAP 快捷键绑定 ====================

            local nmap = require('utils.keymap').nmap
            -- F 键系列（标准调试快捷键）
            nmap('<F5>', dap.continue, 'DAP: 继续 / 开始调试')
            nmap('<F9>', dap.toggle_breakpoint, 'DAP: 切换断点')
            nmap('<F10>', dap.step_over, 'DAP: 步过')
            nmap('<F11>', dap.step_into, 'DAP: 步入')
            nmap('<F12>', dap.step_out, 'DAP: 步出')
            -- Leader 前缀系列
            nmap('<leader>db', dap.toggle_breakpoint, 'DAP: 切换断点')
            nmap('<leader>dB', function()
                dap.set_breakpoint(vim.fn.input('断点条件: '))
            end, 'DAP: 条件断点')
            nmap('<leader>dl', function()
                dap.set_breakpoint(nil, nil, vim.fn.input('日志信息: '))
            end, 'DAP: 日志断点')
            nmap('<leader>dc', dap.continue, 'DAP: 继续执行')
            nmap('<leader>dr', dap.repl.toggle, 'DAP: 切换 REPL')
            nmap('<leader>dt', dap.terminate, 'DAP: 终止调试')
            -- nmap('<leader>du', dapui.toggle, 'DAP: 切换调试界面')
            nmap('<leader>du', '<cmd>DapViewToggle<CR>', 'DAP: 切换调试界面')
            -- 快速设置条件断点（光标行）
            nmap('<leader>dC', function()
                dap.set_breakpoint(vim.fn.input('条件: '))
            end, 'DAP: 当前行条件断点')
            -- 快速日志断点（不暂停，打印变量）
            nmap('<leader>dL', function()
                dap.set_breakpoint(nil, nil, vim.fn.input('日志信息 (用 {var} 占位): '))
            end, 'DAP: 当前行日志断点')
            -- 清空所有断点
            nmap('<leader>dX', dap.clear_breakpoints, 'DAP: 清空所有断点')

            require('which-key').add({
                { '<leader>d', group = '调试 DAP' },
            })
        end,
    },
}

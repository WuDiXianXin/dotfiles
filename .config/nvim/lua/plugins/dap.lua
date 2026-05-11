vim.pack.add({
    {
        src = 'https://github.com/mfussenegger/nvim-dap',
        branch = 'master',
    },
    {
        src = 'https://github.com/rcarriga/nvim-dap-ui',
        branch = 'master',
    },
    {
        src = 'https://github.com/nvim-neotest/nvim-nio',
        branch = 'master',
    },
})

local dap = require('dap')
local dapui = require('dapui')
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
vim.api.nvim_set_hl(0, 'DapBreakpoint', {
    fg = colors.red,
    bold = true,
})
vim.api.nvim_set_hl(0, 'DapBreakpointCondition', { fg = colors.orange, bold = true })
vim.api.nvim_set_hl(0, 'DapStopped', { fg = colors.green, bg = colors.bg_highlight, bold = true })
vim.api.nvim_set_hl(0, 'DapLogPoint', { fg = colors.blue, bold = true })
vim.api.nvim_set_hl(0, 'DapBreakpointRejected', { fg = colors.dark5, bold = true })

-- ==================== LLDB (codelldb) 适配器 ====================
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
-- ==================== Rust 专用智能配置 ====================
dap.configurations.rust = {
    {
        name = 'Launch (Cargo)',
        type = 'lldb',
        request = 'launch',
        program = function()
            -- 后台自动构建
            vim.fn.jobstart({ 'cargo', 'build' }, { detach = true })
            -- 获取 cargo metadata
            local metadata_json =
                vim.json.decode(table.concat(vim.fn.systemlist('cargo metadata --format-version=1 --no-deps'), ''))
            local target_dir = metadata_json.target_directory
            -- 关键：找到当前缓冲区文件所属的 package
            local current_file = vim.fn.expand('%:p') -- 当前文件绝对路径
            local current_package_name = nil
            for _, pkg in ipairs(metadata_json.packages) do
                for _, target in ipairs(pkg.targets) do
                    -- 如果 target 有 src_path，且当前文件路径包含该 src_path，则属于这个 package
                    if target.src_path and string.find(current_file, target.src_path, 1, true) then
                        -- 如果是 bin 类型（可执行），优先用它
                        if vim.tbl_contains(target.kind, 'bin') then
                            current_package_name = pkg.name
                            goto found
                        end
                    end
                end
            end
            ::found::
            if not current_package_name then
                -- 保底：如果没找到，用当前目录名
                current_package_name = vim.fn.fnamemodify(vim.fn.getcwd(), ':t')
            end
            return target_dir .. '/debug/' .. current_package_name
        end,
        cwd = '${workspaceFolder}',
        stopOnEntry = false,
        args = function()
            -- 可选：支持传入运行时参数
            local input = vim.fn.input('Args: ', '')
            return vim.split(input, ' ')
        end,
        postRunCommands = {
            'process handle SIGPIPE -n true -p true -s false',
        }, -- 忽略管道信号
    },
}
-- ==================== dap-ui 界面配置 ====================
dapui.setup({
    layouts = {
        {
            elements = {
                { id = 'scopes', size = 0.25 }, -- 变量作用域
                { id = 'breakpoints', size = 0.25 }, -- 断点列表
                { id = 'stacks', size = 0.25 }, -- 调用栈
                { id = 'watches', size = 0.25 }, -- 监视表达式
            },
            size = 40,
            position = 'left',
        },
        {
            elements = { 'repl', 'console' },
            size = 0.25,
            position = 'bottom',
        },
    },
    floating = {
        border = 'rounded',
        max_width = 0.6,
        max_height = 0.6,
    },
    controls = {
        enabled = false,
    },
    icons = {
        expanded = '▾',
        collapsed = '▸',
        current_frame = '▸',
    },
    element_mappings = {
        scopes = { expand = { '<CR>', 'o' } },
    },
})

-- 调试会话开始时自动打开 UI，结束时自动关闭
dap.listeners.before.attach.dapui_config = function()
    dapui.open()
end
dap.listeners.before.launch.dapui_config = function()
    dapui.open()
end
dap.listeners.before.event_terminated.dapui_config = function()
    dapui.close()
end
dap.listeners.before.event_exited.dapui_config = function()
    dapui.close()
end

-- ==================== DAP 快捷键绑定 ====================
local nmap = function(lhs, rhs, desc)
    vim.keymap.set('n', lhs, rhs, {
        noremap = true,
        silent = true,
        nowait = true,
        desc = desc,
    })
end
-- 鼠标支持
nmap('<2-LeftMouse>', "<cmd>lua require('dapui').eval()<CR>", '双击变量弹出值')
-- F 键系列（标准调试快捷键）
nmap('<F5>', dap.continue, 'DAP: 继续 / 开始调试')
nmap('<F9>', dap.toggle_breakpoint, 'DAP: 切换断点')
nmap('<F10>', dap.step_over, 'DAP: 步过')
nmap('<F11>', dap.step_into, 'DAP: 步入')
nmap('<F12>', dap.step_out, 'DAP: 步出')
-- Leader 前缀系列（推荐日常使用，避免与系统冲突）
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
nmap('<leader>du', dapui.toggle, 'DAP: 切换调试界面')
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

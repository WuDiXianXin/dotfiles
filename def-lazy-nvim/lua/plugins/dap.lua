return {
  {
    'mfussenegger/nvim-dap',
    branch = 'master',
    lazy = true,
    keys = { -- 同之前，保持懒加载
      { '<F9>', mode = 'n' }, -- 切换断点（最常用）
      { '<leader>db', mode = 'n' }, -- 切换断点
      { '<leader>dB', mode = 'n' }, -- 全局条件断点
      { '<leader>dl', mode = 'n' }, -- 全局日志断点
      { '<leader>dC', mode = 'n' }, -- 当前行条件断点
      { '<leader>dL', mode = 'n' }, -- 当前行日志断点
    },
    dependencies = {
      { 'rcarriga/nvim-dap-ui', branch = 'master' },
      { 'nvim-neotest/nvim-nio', branch = 'master' },
      { 'theHamsta/nvim-dap-virtual-text', branch = 'master' },
    },
    config = function()
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
        command = vim.fn.expand('~/lldb/extension/adapter/codelldb'),
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
          max_width = 0.6, -- 新增：限制浮动窗口宽度
          max_height = 0.6, -- 新增：限制高度
        },
        controls = { enabled = true },
        icons = { -- 新增：美化展开/折叠图标
          expanded = '▾',
          collapsed = '▸',
          current_frame = '▸',
        },
        element_mappings = { -- 新增：Scopes 面板回车展开变量
          scopes = { expand = { '<CR>', 'o' } },
        },
      })
      -- 调试会话开始时自动打开 UI，结束时自动关闭
      dap.listeners.after.event_initialized['dapui_config'] = dapui.open
      dap.listeners.before.event_terminated['dapui_config'] = dapui.close
      dap.listeners.before.event_exited['dapui_config'] = dapui.close
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
      require('mini.clue').ensure_buf_triggers()
    end,
  },
  -- dap-ui 保持懒加载，由 nvim-dap 自动触发
  {
    'rcarriga/nvim-dap-ui',
    branch = 'master',
    lazy = true,
  },
  {
    'theHamsta/nvim-dap-virtual-text',
    branch = 'master',
    lazy = true, -- 强烈建议加这一行，实现懒加载
    config = function()
      require('nvim-dap-virtual-text').setup({
        enabled = true, -- 启用插件
        highlight_changed_variables = true, -- 变量值变化时高亮（推荐开）
        show_stop_reason = true, -- 停在断点时显示原因（如 breakpoint hit）
        -- 可选美化（推荐加这些）
        virt_text_pos = 'eol', -- 显示在行尾（不遮代码）
        all_frames = false, -- 只显示当前栈帧变量（默认就行）
        highlight_new_as_changed = false, -- 新变量不标记为变化
      })
    end,
  },
}

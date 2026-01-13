return {
  {
    'folke/which-key.nvim',
    branch = 'main',
    event = 'VeryLazy',
    opts = {
      preset = 'modern',
      -- 智能延迟：插件相关键立即显示，其他延迟 200ms（防误触）
      delay = function(ctx)
        return ctx.plugin and 0 or 200
      end,

      -- 只显示有 desc 的映射（保持干净）
      filter = function(mapping)
        return mapping.desc and mapping.desc ~= ''
      end,

      -- 启用官方内置插件
      plugins = {
        marks = true, -- ' / ` 触发显示标记列表
        registers = true, -- " / <C-r> 触发显示寄存器列表
        spelling = false, -- 禁用拼写建议（非核心需求，减少干扰）
        presets = {
          operators = true, -- d/y/c 等操作符的原生绑定提示
          motions = true, -- 原生移动快捷键提示
          windows = true, -- <C-w> 窗口操作提示
          g = true, -- g 前缀原生绑定提示（和你的 LSP g 前缀互补）
          z = true, -- z 前缀折叠/拼写提示
          nav = true, -- 方向键导航提示（h j k l 等）
        },
      },
      -- 窗口样式
      win = {
        border = 'rounded', -- 和 LazyVim 诊断窗口/终端风格一致
        no_overlap = true, -- 避免弹窗覆盖光标
        padding = { 1, 2 }, -- 官方默认内边距，视觉更舒适
        title = true,
        title_pos = 'center',
        wo = { winblend = 10 }, -- 轻微透明，更协调 tokyonight
      },
      layout = {
        height = { min = 4, max = 30 },
        width = { min = 20, max = 40 },
        spacing = 4, -- 组间距更宽松，阅读更舒适
        align = 'center',
      },
      icons = {
        breadcrumb = '»',
        separator = '➜',
        group = ' ', -- 用折叠图标表示组，更直观（需要 Nerd Font）
        ellipsis = '…',
        mappings = true,
        rules = {}, -- 可自定义图标规则（目前无需）
      },
      show_help = false, -- 隐藏默认帮助提示
      show_keys = true, -- 显示当前按下的键

      -- 禁用内置触发键日志（减少干扰）
      disable = { filetypes = { 'TelescopePrompt' } },
    },
    config = function(_, opts)
      -- 初始化 which-key（LazyVim 中无需手动 pcall，lazy 会自动处理加载失败）
      local wk = require('which-key')
      wk.setup(opts)

      -- ==================== 分组注册（推荐新写法：wk.add） ====================
      wk.add({
        -- Leader 顶级分组
        { '<leader>', group = 'Leader 主菜单' },

        -- 功能大类
        { '<leader>b', group = '缓冲区管理' },
        { '<leader>t', group = '标签页操作' },
        { '<leader>w', group = '窗口操作' },
        { '<leader>e', group = '文件/探索器' },
        { '<leader>c', group = '内容/代码操作/ Crates / Cargo' },
        { '<leader>f', group = '查找/模糊搜索' },
        { '<leader>l', group = '诊断/位置列表' },
        { '<leader>d', group = '调试 (DAP)' },
        -- 非 Leader 前缀
        { 'g', group = '跳转 / Goto' },
        { 'gr', group = 'LSP 符号操作' },
        { '[', group = '上一个' },
        { ']', group = '下一个' },

        -- v 模式
        { '<leader>', group = 'Leader 主菜单', mode = 'v' },
        { '<leader>c', group = '内容/代码操作', mode = 'v' },
      })

      -- 全局快捷键查看（? 键）
      vim.keymap.set('n', '?', function()
        wk.show({ global = true })
      end, { desc = '查看所有快捷键 (WhichKey)' })
    end,
  },
}

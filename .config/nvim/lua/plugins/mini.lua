return {
  {
    'nvim-mini/mini.nvim',
    branch = 'main',
    version = '*',
    lazy = false,
    priority = 1000,
    config = function()
      -- ==================== 核心编辑体验 ====================
      require('mini.surround').setup()
      require('mini.ai').setup({
        -- 建议把搜索范围调大一点，避免找不到的情况
        n_lines = 500,
        -- 很多人喜欢这个搜索策略
        search_method = 'cover_or_next',
      })

      require('mini.pairs').setup()
      require('mini.indentscope').setup({
        symbol = '▏', -- 或 '│' 等细线
        options = {
          try_as_border = true, -- ★ 必须！让头部行（如 if/for/def）被识别为边界，从而能缩小到内层
          indent_at_cursor = true, -- 光标左右移动时动态调整参考缩进
          border = 'both',
        },
        draw = {
          delay = 50,
          animation = require('mini.indentscope').gen_animation.none(), -- 关动画，避免延迟迷惑
          predicate = function() return true end,                       -- 测试阶段强制画所有（可选）
        },
      })

      -- ==================== 文件 & 导航 ====================
      require('mini.files').setup({
        windows = {
          preview = true,
          width_focus = 25,
          width_preview = 80,
        },
      })
      require('mini.pick').setup()
      require('mini.extra').setup()
      require('mini.visits').setup()

      -- ==================== 美观 & 辅助 ====================
      require('mini.hipatterns').setup()
      require('mini.clue').setup()
      require('mini.bracketed').setup()

      -- ==================== Icons & 整合 ====================
      -- 主题颜色
      local tokyo_colors = require('tokyonight.colors').setup()

      -- 配置 mini.icons
      local mini_icons = require('mini.icons')
      mini_icons.setup({
        style = 'glyph',
        file = {
          README = { glyph = '󰆈', hl = 'MiniIconsYellow' },
          ['README.md'] = { glyph = '󰆈', hl = 'MiniIconsYellow' },
        },
        filetype = {
          bash = { glyph = '󱆃', hl = 'MiniIconsGreen' },
          sh = { glyph = '󱆃', hl = 'MiniIconsGrey' },
          toml = { glyph = '󱄽', hl = 'MiniIconsOrange' },
        },
      })

      mini_icons.mock_nvim_web_devicons()

      -- LSP 图标集成
      mini_icons.tweak_lsp_kind('prepend')

      -- 诊断配置
      vim.diagnostic.config({
        signs = {
          -- 使用 mini.icons 的 LSP 图标 + 空格
          text = {
            [vim.diagnostic.severity.ERROR] = (mini_icons.get('lsp', 'Error')[1] or '') .. ' ',
            [vim.diagnostic.severity.WARN] = (mini_icons.get('lsp', 'Warning')[1] or '') .. ' ',
            [vim.diagnostic.severity.INFO] = (mini_icons.get('lsp', 'Information')[1] or '') .. ' ',
            [vim.diagnostic.severity.HINT] = (mini_icons.get('lsp', 'Hint')[1] or '') .. ' ',
          },
          severity = { min = vim.diagnostic.severity.HINT },
        },
        float = {
          border = 'rounded',
          source = 'if_many',
        },
        virtual_lines = {
          current_line = true,
        },
      })

      -- 强制定义诊断 signs 高亮（用你主题的实际颜色，左侧图标与底部状态栏统一）
      vim.api.nvim_set_hl(0, 'DiagnosticSignError', { fg = tokyo_colors.error })  -- 你的实际错误色：#c53b53
      vim.api.nvim_set_hl(0, 'DiagnosticSignWarn', { fg = tokyo_colors.warning }) -- 你的实际警告色：#ffc777
      vim.api.nvim_set_hl(0, 'DiagnosticSignInfo', { fg = tokyo_colors.info })    -- 你的实际信息色：#0db9d7
      vim.api.nvim_set_hl(0, 'DiagnosticSignHint', { fg = tokyo_colors.hint })    -- 你的实际提示色：#4fd6be
    end,
  },
}

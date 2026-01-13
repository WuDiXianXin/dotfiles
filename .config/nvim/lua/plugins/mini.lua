return {
  {
    'nvim-mini/mini.nvim',
    branch = 'main',
    version = '*',
    lazy = false,
    config = function()
      -- 配置 mini.ai
      -- require('mini.ai').setup({
      --   mappings = {
      --     goto_left = '[',
      --     got_right = ']',
      --   },
      -- })

      -- 配置 mini.files
      require('mini.files').setup({
        windows = {
          preview = true,
          width_focus = 25,
          width_preview = 80,
        },
      })

      -- 引入你主题的实际颜色（和 colortheme.lua 中的 opts 保持一致：transparent=true）
      local tokyo_colors = require('tokyonight.colors').setup({ transparent = true })

      -- local tokyo_util = require("tokyonight.util")

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

      -- 诊断配置：使用新方式（推荐，无警告）
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
      vim.api.nvim_set_hl(0, 'DiagnosticSignError', { fg = tokyo_colors.error }) -- 你的实际错误色：#c53b53
      vim.api.nvim_set_hl(0, 'DiagnosticSignWarn', { fg = tokyo_colors.warning }) -- 你的实际警告色：#ffc777
      vim.api.nvim_set_hl(0, 'DiagnosticSignInfo', { fg = tokyo_colors.info }) -- 你的实际信息色：#0db9d7
      vim.api.nvim_set_hl(0, 'DiagnosticSignHint', { fg = tokyo_colors.hint }) -- 你的实际提示色：#4fd6be

      -- 配置 mini.pick
      require('mini.pick').setup()
    end,
  },
}

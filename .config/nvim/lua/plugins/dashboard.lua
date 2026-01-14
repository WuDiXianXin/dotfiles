---@diagnostic disable: undefined-global
return {
  'nvimdev/dashboard-nvim',
  event = 'VimEnter',
  config = function()
    require('dashboard').setup({
      theme = 'hyper', -- 明确使用 hyper 主题

      -- 常用核心选项
      shortcut_type = 'letter', -- 使用字母做快捷键（a,b,c...）
      shuffle_letter = false, -- 字母不随机排序，保持顺序
      change_to_vcs_root = true, -- 打开文件时自动 cd 到 git 项目根目录

      -- hyper 主题专属配置（重点在这里）
      config = {
        week_header = {
          enable = false, -- 显示当前周历
        },

        -- 自定义头部（优先级比 week_header 高，需要关闭 week_header）
        header = {
          '',
          '███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗',
          '████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║',
          '██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║',
          '██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║',
          '██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║',
          '╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝',
          '',
        },
        -- header = {
        --   "",
        --   "   ╔════════════════════════════════════════════╗",
        --   "   ║          每天，代码，性欲，满满！          ║",
        --   "   ║  ██████╗██████╗ ███████╗██╗   ██╗███████╗  ║",
        --   "   ║ ██╔════╝██╔══██╗██╔════╝██║   ██║██╔════╝  ║",
        --   "   ║ ██║     ██████╔╝█████╗  ██║   ██║███████╗  ║",
        --   "   ║ ██║     ██╔══██╗██╔══╝  ╚██╗ ██╔╝╚════██║  ║",
        --   "   ║ ╚██████╗██║  ██║███████╗ ╚████╔╝ ███████║  ║",
        --   "   ║  ╚═════╝╚═╝  ╚═╝╚══════╝  ╚═══╝  ╚══════╝  ║",
        --   "   ║         CODE HARD • FUCK HARD • FULL!      ║",
        --   "   ╚════════════════════════════════════════════╝",
        --   "          🔥💻🍆💦  冲！每天都满电！  🔥💻🍆💦   ",
        --   "",
        -- },
        -- header = {
        --   "",
        --   "   ╔════════════════════════════════════════════╗",
        --   "   ║          每天，代码，性欲，满满！          ║",
        --   "   ║       CODE HARD • FUCK HARD • FULL!        ║",
        --   "   ╚════════════════════════════════════════════╝",
        --   "        🔥💻🍆💦  冲！每天都满电！  🔥💻🍆💦     ",
        --   "",
        -- },

        -- 快捷键按钮（最常用自定义部分）
        shortcut = {
          { desc = '󰊳 Update', group = '@property', action = 'Lazy update', key = 'u' },

          { desc = ' New Buffer', group = 'DiagnosticHint', action = 'enew', key = 'n' },
          -- 你可以继续加很多，例如下面，但是我没有 Mason ，就注释
          -- { desc = '  Mason', group = 'DiagnosticOk', action = 'Mason', key = 'm' },
        },

        -- ★ 这里是关键：覆盖默认的 Telescope action
        project = {
          enable = true,
          action = function(path)
            MiniPick.builtin.files({ cwd = path })
          end,
        },

        -- 项目和最近文件显示个数（默认都比较合理，可调小一点更清爽）
        mru = { limit = 6 },

        -- footer 可以放一句名言、版本信息等
        footer = { '', 'Sharp tools → good work ✦' },
      },
    })
  end,
}

return {
  'yetone/avante.nvim',
  event = 'VeryLazy',
  version = false,
  build = vim.fn.has('win32') ~= 0 and 'powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false'
    or 'make',

  opts = {
    provider = 'minimax',
    providers = {
      minimax = {
        __inherited_from = 'claude',
        endpoint = 'https://api.minimaxi.com/anthropic', -- 推荐完整路径
        model = 'MiniMax-M2.1',
        api_key_name = 'MINIMAX_API_KEY',
        timeout = 60000,
        extra_request_body = {
          temperature = 0.1,
          max_tokens = 8192,
        },
      },
    },
  },

  dependencies = {
    'nvim-lua/plenary.nvim',
    'MunifTanjim/nui.nvim',
    {
      'HakonHarnes/img-clip.nvim',
      event = 'VeryLazy',
      opts = {
        default = {
          embed_image_as_base64 = false,
          prompt_for_file_name = false,
          drag_and_drop = { insert_mode = true },
          use_absolute_path = true,
        },
      },
    },
    'Kaiser-Yang/blink-cmp-avante',
  },

  config = function(_, opts)
    require('avante').setup(opts)

    -- 一键清除所有 selected files（优化版：强制清空 + 自动重新打开 sidebar）
    vim.api.nvim_create_user_command('AvanteClearSelectedFiles', function()
      local avante = require('avante')
      local sidebar = avante.get()

      if sidebar and sidebar.file_selector and sidebar.file_selector.selected_files then
        -- 直接清空内部表
        sidebar.file_selector.selected_files = {}

        -- 如果有 refresh 方法，调用它（部分版本有）
        if sidebar.refresh then
          sidebar:refresh()
        end

        vim.notify('Avante: All selected files cleared!', vim.log.levels.INFO)
      else
        -- 如果 sidebar/file_selector 不可用，强制重新打开侧边栏（这会重建实例并清空）
        vim.cmd('AvanteToggle') -- 先关闭（如果已开）
        vim.cmd('AvanteToggle') -- 再打开，selected files 会自动重置为空
        vim.notify('Avante: Sidebar reopened and selected files cleared!', vim.log.levels.INFO)
      end
    end, { desc = 'Clear all Avante selected files' })

    -- 快捷键（在任何模式下都可用）
    vim.keymap.set('n', '<Leader>aC', '<cmd>AvanteClearSelectedFiles<CR>', {
      desc = 'Avante: Clear all selected files',
      silent = true,
    })

    require('mini.clue').ensure_buf_triggers()
  end,
}

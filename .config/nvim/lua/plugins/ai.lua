return {
  'yetone/avante.nvim',
  version = false,
  build = 'make BUILD_FROM_SOURCE=true',
  event = 'VeryLazy',
  ---@module 'avante'
  ---@type avante.Config
  opts = {
    instructions_file = 'avante.md',
    provider = 'minimax',
    providers = {
      minimax = {
        __inherited_from = 'claude',
        endpoint = 'https://api.minimaxi.com/anthropic',
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
    --- The below dependencies are optional,
    'Kaiser-Yang/blink-cmp-avante',
    'folke/snacks.nvim',
    {
      -- support for image pasting
      'HakonHarnes/img-clip.nvim',
      event = 'VeryLazy',
      opts = {
        -- recommended settings
        default = {
          embed_image_as_base64 = false,
          prompt_for_file_name = false,
          drag_and_drop = { insert_mode = true },
          -- required for Windows users
          use_absolute_path = true,
        },
      },
    },
    {
      -- Make sure to set this up properly if you have lazy=true
      'MeanderingProgrammer/render-markdown.nvim',
      opts = {
        file_types = { 'markdown', 'Avante' },
      },
      ft = { 'markdown', 'Avante' },
    },
  },
}

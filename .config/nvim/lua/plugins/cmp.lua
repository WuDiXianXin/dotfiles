return {
  {
    'saghen/blink.cmp',
    branch = 'main',
    build = 'cargo build --release', -- 可选：启用 Rust fuzzy（更快，但需 Rust-night）
    event = 'InsertEnter',           -- 插入模式懒加载
    dependencies = {
      { 'xzbdmw/colorful-menu.nvim',    branch = 'master' },
      { 'rafamadriz/friendly-snippets', branch = 'main' },
      { 'L3MON4D3/LuaSnip',             branch = 'master' },
      'Kaiser-Yang/blink-cmp-avante',
    },
    opts = {
      keymap = {
        preset = 'none',

        -- 上下键选择补全项
        ['<Up>'] = { 'select_prev', 'fallback' },
        ['<Down>'] = { 'select_next', 'fallback' },

        -- Ctrl+空格：只显示代码片段补全
        ['<C-space>'] = { function(cmp) cmp.show({ providers = { 'snippets' } }) end },

        -- Ctrl+n/Ctrl+p：选择下/上一个补全项（符合通用习惯）
        ['<C-n>'] = { 'select_next', 'fallback' },
        ['<C-p>'] = { 'select_prev', 'fallback' },

        -- ESC键 - 优先隐藏补全菜单，无补全则执行默认ESC行为（推荐）
        ['<Esc>'] = { 'hide', 'fallback' },

        -- Ctrl+e - 彻底取消补全（回滚内容+隐藏菜单）
        ['<C-e>'] = { 'cancel' },

        -- 确认候选项
        ['<C-y>'] = { 'accept' },
      },

      cmdline = {
        enabled = true,
        completion = { menu = { auto_show = true } },
      },

      appearance = {
        nerd_font_variant = 'mono',
      },

      completion = {
        documentation = { auto_show = true },
        menu = {
          draw = {
            columns = { { 'kind_icon' }, { 'label', gap = 1 } },
            components = {
              label = {
                text = function(ctx)
                  return require('colorful-menu').blink_components_text(ctx)
                end,
                highlight = function(ctx)
                  return require('colorful-menu').blink_components_highlight(ctx)
                end,
              },
            },
          },
        },
      },

      signature = { enabled = true },

      sources = {
        default = { 'path', 'lsp', 'snippets', 'buffer', 'avante' },
        providers = {
          buffer = { enabled = true, max_items = 6 },
          snippets = { score_offset = 99 },
          avante = {
            module = 'blink-cmp-avante',
            name = 'Avante',
          },
        },
      },

      -- -- 新增：动态添加 crates 来源（仅当 crates.nvim 已加载时）
      -- setup = function()
      --   local cmp = require('blink.cmp')
      --   -- 检查 crates.nvim 是否已加载（通过 pcall 安全检测）
      --   local ok, crates = pcall(require, 'crates')
      --   if ok then
      --     cmp.register_source('crates', crates.cmp_source())
      --   end
      -- end,

      fuzzy = {
        implementation = 'prefer_rust_with_warning',
      },

      snippets = {
        preset = 'luasnip',
      },
    },
  },

  {
    'L3MON4D3/LuaSnip',
    branch = 'master',
    build = 'make install_jsregexp',
    lazy = true,
    config = function()
      local ls = require('luasnip')
      ls.config.set_config({
        history = true,
        update_events = 'TextChanged,TextChangedI,TextChangedP',
        delete_check_events = 'TextChanged,InsertLeave',
        enable_autosnippets = false,
      })

      -- 懒加载 friendly-snippets，只加载指定语言
      require('luasnip.loaders.from_vscode').lazy_load({
        include = { 'lua', 'rust', 'markdown', 'bash', 'fish', 'c', 'cpp' },
      })
    end,
  },

  {
    'rafamadriz/friendly-snippets',
    branch = 'main',
    lazy = true,
  },

  {
    'xzbdmw/colorful-menu.nvim',
    branch = 'master',
    lazy = true,
    opts = {}, -- 可选：这里配置 colorful-menu 的自定义选项（如 lsp 特定高亮）
  },
}

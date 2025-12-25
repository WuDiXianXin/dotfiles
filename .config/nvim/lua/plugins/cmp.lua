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
    },
    opts = {
      keymap = { preset = 'default' },

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
                  return require('colorful-menu').blink_components_highlight(
                    ctx
                  )
                end,
              },
            },
          },
        },
      },

      signature = { enabled = true },

      sources = {
        default = { 'path', 'lsp', 'snippets', 'buffer' },
        providers = {
          buffer = { enabled = true, max_items = 6 },
          snippets = { score_offset = 99 },
        },
      },

      -- 新增：动态添加 crates 来源（仅当 crates.nvim 已加载时）
      setup = function()
        local cmp = require('blink.cmp')
        -- 检查 crates.nvim 是否已加载（通过 pcall 安全检测）
        local ok, crates = pcall(require, 'crates')
        if ok then
          cmp.register_source('crates', crates.cmp_source())
        end
      end,

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
        include = { 'lua', 'rust', 'markdown', 'bash', 'fish' },
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

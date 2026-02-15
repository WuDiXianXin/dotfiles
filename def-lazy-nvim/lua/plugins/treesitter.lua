return {
  {
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',
    build = ':TSUpdate',
    lazy = false,
    dependencies = {
      { 'nvim-treesitter/nvim-treesitter-textobjects', branch = 'main' },
    },
    config = function()
      -- 手动安装所需 parsers（异步）
      require('nvim-treesitter').install({
        'bash',
        'fish',
        'lua',
        'rust',
        'markdown',
        'markdown_inline',
        'c',
        'cpp',
        'python',
        'html',
        'latex',
        'typst',
        'yaml',
      })

      -- 大文件禁用高亮/indent（直接用 vim.treesitter API）
      vim.api.nvim_create_autocmd('BufEnter', {
        callback = function(args)
          local buf = args.buf
          local max_filesize = vim.g.bigfile_size or 2 * 1024 * 1024
          local buf_name = vim.api.nvim_buf_get_name(buf)
          if buf_name == '' then
            return
          end
          local ok, stats = pcall(vim.uv.fs_stat, buf_name)
          if ok and stats and stats.size > max_filesize then
            vim.treesitter.stop(buf) -- 停止 treesitter 解析
          end
        end,
      })
    end,
  },
  {
    'nvim-treesitter/nvim-treesitter-textobjects',
    branch = 'main',
    opts = {
      select = {
        enable = true,
        lookahead = true, -- 自动向前查找，类似 targets.vim
        include_surrounding_whitespace = false,
      },
      move = {
        enable = true,
        set_jumps = true, -- 记录到 jumplist，可用 Ctrl-o/i 回退
      },
      swap = {
        enable = true,
      },
    },
    config = function(_, opts)
      require('nvim-treesitter-textobjects').setup(opts)
      local select = require('nvim-treesitter-textobjects.select')
      local move = require('nvim-treesitter-textobjects.move')
      local swap = require('nvim-treesitter-textobjects.swap')
      local repeat_move = require('nvim-treesitter-textobjects.repeatable_move')

      -- 使用 buffer-local 映射，避免全局污染
      -- LspAttach 防止 触发时没有 配置语言，或者打开普通文本时使用报错。
      vim.api.nvim_create_autocmd('LspAttach', {
        callback = function(ev)
          -- 统一的键映射选项
          local keymap_opts = { noremap = true, silent = true, nowait = true, buffer = ev.buf }

          local function def_set_maps(oper, mode, maps, extra_arg)
            for _, map in ipairs(maps) do
              keymap_opts.desc = 'TS: ' .. map.desc
              vim.keymap.set(mode, map.lhs, function()
                if map.query then
                  if extra_arg then
                    if map.func then
                      oper[map.func](map.query, extra_arg)
                    else
                      oper.select_textobject(map.query, extra_arg)
                    end
                  else
                    oper[map.func](map.query)
                  end
                else
                  oper[map.func]()
                end
              end, keymap_opts)
            end
          end

          -- ===================== Select 文本对象 =====================
          local select_maps = {
            { lhs = 'aF', query = '@function.outer', desc = '函数（外层）' },
            { lhs = 'iF', query = '@function.inner', desc = '函数（内层）' },
            { lhs = 'ac', query = '@class.outer', desc = '类（外层）' },
            { lhs = 'ic', query = '@class.inner', desc = '类（内层）' },
            { lhs = 'al', query = '@loop.outer', desc = '循环（外层）' },
            { lhs = 'il', query = '@loop.inner', desc = '循环（内层）' },
            { lhs = 'ao', query = '@conditional.outer', desc = '条件语句（外层）' },
            { lhs = 'io', query = '@conditional.inner', desc = '条件语句（内层）' },
            { lhs = 'as', query = '@statement.outer', desc = '语句（外层）' },
            { lhs = 'is', query = '@statement.inner', desc = '语句（内层）' },
            { lhs = 'a/', query = '@comment.outer', desc = '注释（外层）' },
            { lhs = 'i/', query = '@comment.inner', desc = '注释（内层）' },
          }

          -- ===================== Move 跳转 =====================
          local move_maps = {
            { lhs = ']f', query = '@function.outer', func = 'goto_next_start', desc = '下一个函数开始' },
            { lhs = '[f', query = '@function.outer', func = 'goto_previous_start', desc = '上一个函数开始' },
            { lhs = ']c', query = '@class.outer', func = 'goto_next_start', desc = '下一个类开始' },
            { lhs = '[c', query = '@class.outer', func = 'goto_previous_start', desc = '上一个类开始' },
            { lhs = ']s', query = '@statement.outer', func = 'goto_next_start', desc = '下一个语句开始' },
            { lhs = '[s', query = '@statement.outer', func = 'goto_previous_start', desc = '上一个语句开始' },
          }

          -- ===================== Swap 参数交换 =====================
          local swap_maps = {
            { lhs = '<leader>a', query = '@parameter.inner', func = 'swap_next', desc = '交换下一个参数' },
            { lhs = '<leader>A', query = '@parameter.inner', func = 'swap_previous', desc = '交换上一个参数' },
          }

          -- ===================== Repeatable Move =====================
          local repeat_move_maps = {
            { lhs = ',', func = 'repeat_last_move_next', desc = '重复上一次向后 move' },
            { lhs = '.', func = 'repeat_last_move_previous', desc = '重复上一次向前 move' },
          }

          def_set_maps(select, { 'x', 'o' }, select_maps, 'textobjects')
          def_set_maps(move, { 'n', 'x', 'o' }, move_maps, 'textobjects')
          def_set_maps(swap, 'n', swap_maps, nil)
          def_set_maps(repeat_move, 'n', repeat_move_maps, nil)

          require('mini.clue').ensure_buf_triggers()
        end,
      })
    end,
  },
}

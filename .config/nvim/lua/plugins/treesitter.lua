return {
  {
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',
    build = ':TSUpdate',
    lazy = false,
    dependencies = { 'nvim-treesitter/nvim-treesitter-textobjects' },
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
    init = function()
      -- 禁用内置 ftplugin 映射，避免冲突
      vim.g.no_plugin_maps = true
    end,
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

      -- 统一的键映射选项
      local keymap_opts = { noremap = true, silent = true, nowait = true }

      -- ===================== Select 文本对象 =====================
      local select_maps = {
        af = { query = '@function.outer', desc = '函数（外层）' },
        ['if'] = { query = '@function.inner', desc = '函数（内层）' },
        ac = { query = '@class.outer', desc = '类（外层）' },
        ic = { query = '@class.inner', desc = '类（内层）' },
        al = { query = '@loop.outer', desc = '循环（外层）' },
        il = { query = '@loop.inner', desc = '循环（内层）' },
        ai = { query = '@conditional.outer', desc = '条件语句（外层）' },
        ii = { query = '@conditional.inner', desc = '条件语句（内层）' },
        as = { query = '@statement.outer', desc = '语句（外层）' },
        ['is'] = { query = '@statement.inner', desc = '语句（内层）' },
        aC = { query = '@comment.outer', desc = '注释（外层）' }, -- 用大写 C 避免与 class 冲突
        iC = { query = '@comment.inner', desc = '注释（内层）' },
      }

      for lhs, info in pairs(select_maps) do
        keymap_opts.desc = 'Treesitter: ' .. info.desc
        vim.keymap.set({ 'x', 'o' }, lhs, function()
          select.select_textobject(info.query, 'textobjects')
        end, keymap_opts)
      end

      -- ===================== Move 跳转 =====================
      -- 使用 buffer-local 映射，避免全局污染（LazyVim 推荐做法）
      vim.api.nvim_create_autocmd('FileType', {
        callback = function(ev)
          local buf = ev.buf
          local move_opts = vim.tbl_extend('force', keymap_opts, { buffer = buf })

          vim.keymap.set({ 'n', 'x', 'o' }, ']f', function()
            move.goto_next_start('@function.outer', 'textobjects')
          end, vim.tbl_extend('force', move_opts, { desc = 'Treesitter: 下一个函数开始' }))
          vim.keymap.set({ 'n', 'x', 'o' }, ']c', function()
            move.goto_next_start('@class.outer', 'textobjects')
          end, vim.tbl_extend('force', move_opts, { desc = 'Treesitter: 下一个类开始' }))
          vim.keymap.set({ 'n', 'x', 'o' }, ']s', function()
            move.goto_next_start('@statement.outer', 'textobjects')
          end, vim.tbl_extend('force', move_opts, { desc = 'Treesitter: 下一个语句开始' }))

          vim.keymap.set({ 'n', 'x', 'o' }, '[f', function()
            move.goto_previous_start('@function.outer', 'textobjects')
          end, vim.tbl_extend('force', move_opts, { desc = 'Treesitter: 上一个函数开始' }))
          vim.keymap.set({ 'n', 'x', 'o' }, '[c', function()
            move.goto_previous_start('@class.outer', 'textobjects')
          end, vim.tbl_extend('force', move_opts, { desc = 'Treesitter: 上一个类开始' }))
          vim.keymap.set({ 'n', 'x', 'o' }, '[s', function()
            move.goto_previous_start('@statement.outer', 'textobjects')
          end, vim.tbl_extend('force', move_opts, { desc = 'Treesitter: 上一个语句开始' }))
        end,
      })

      -- ===================== Swap 参数交换 =====================
      vim.keymap.set('n', '<leader>a', function()
        swap.swap_next('@parameter.inner')
      end, vim.tbl_extend('force', keymap_opts, { desc = 'Treesitter: 交换到下一个参数' }))

      vim.keymap.set('n', '<leader>A', function()
        swap.swap_previous('@parameter.inner')
      end, vim.tbl_extend('force', keymap_opts, { desc = 'Treesitter: 交换到上一个参数' }))

      -- ===================== Repeatable Move =====================
      vim.keymap.set(
        { 'n', 'x', 'o' },
        ';',
        repeat_move.repeat_last_move_next,
        vim.tbl_extend('force', keymap_opts, { desc = 'Treesitter: 重复上一次 move（向前）' })
      )

      vim.keymap.set(
        { 'n', 'x', 'o' },
        ',',
        repeat_move.repeat_last_move_previous,
        vim.tbl_extend('force', keymap_opts, { desc = 'Treesitter: 重复上一次 move（向后）' })
      )
    end,
  },
}

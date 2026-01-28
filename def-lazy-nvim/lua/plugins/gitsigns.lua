return {
  'lewis6991/gitsigns.nvim',
  branch = 'main',
  event = { 'BufReadPre', 'BufNewFile' },
  config = function()
    local status_ok, gitsigns = pcall(require, 'gitsigns')
    if not status_ok then
      vim.notify('gitsigns.nvim 加载失败！', vim.log.levels.ERROR)
      return
    end
    -- 先定義顏色（你原本用的 tokyonight 顏色）
    local colors = require('tokyonight.colors').setup({ transparent = true })

    -- 手動建立高亮組（新版最推薦做法）
    vim.api.nvim_set_hl(0, 'GitSignsAdd', { fg = colors.git.add })
    vim.api.nvim_set_hl(0, 'GitSignsChange', { fg = colors.git.change })
    vim.api.nvim_set_hl(0, 'GitSignsDelete', { fg = colors.git.delete })
    vim.api.nvim_set_hl(0, 'GitSignsTopDelete', { fg = colors.git.delete })
    vim.api.nvim_set_hl(0, 'GitSignsChangeDelete', { fg = colors.warning })
    vim.api.nvim_set_hl(0, 'GitSignsUntracked', { fg = colors.comment })

    gitsigns.setup({
      -- 未暂存（unstaged）变更符号
      signs = {
        add = { text = '┃' },
        change = { text = '┃' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
        untracked = { text = '┆' },
      },
      -- 已暂存（staged）变更符号
      signs_staged = {
        add = { text = '⊕' },
        change = { text = '⊛' },
        delete = { text = '⊖' },
        topdelete = { text = '⊤' },
        changedelete = { text = '⊚' },
        -- untracked = { text = '┆' },
      },
      signs_staged_enable = true, -- 主动启用暂存区符号显示（默认关闭）
      -- 可通过命令切换
      signcolumn = true, -- 显示符号列（默认开启）
      numhl = true, -- 高亮变更行的行号（便于快速定位变更）
      linehl = false, -- 关闭整行高亮（避免界面过于杂乱）
      word_diff = false, -- 关闭单词级内联diff（保持界面简洁）
      -- Git 目录监控配置
      watch_gitdir = {
        interval = 1000, -- 1秒监控一次
        follow_files = true, -- 跟随文件重命名/移动
      },
      auto_attach = true, -- 自动为缓冲区附加 gitsigns 功能
      attach_to_untracked = true, -- 为未追踪文件也启用（显示 untracked 符号）
      current_line_blame = false, -- 默认关闭行内 blame（按需开启，减少性能消耗）
      current_line_blame_opts = {
        virt_text = true,
        virt_text_pos = 'eol', -- 'eol' | 'overlay' | 'right_align'
        delay = 1000,
        ignore_whitespace = false,
        virt_text_priority = 100,
        use_focus = true,
      },
      current_line_blame_formatter = '<author>, <author_time:%R> - <summary>',
      sign_priority = 6,
      update_debounce = 200,
      status_formatter = nil, -- 禁用默认状态格式化（让 heirline 处理）
      max_file_length = 40000, -- 大文件禁用（避免卡顿）
      preview_config = {
        -- 变更预览窗口配置（简洁美观）
        style = 'minimal',
        relative = 'cursor',
        row = 0,
        col = 1,
      },

      -- 推荐的按键映射（超级实用！）
      on_attach = function(bufnr)
        local gs = package.loaded.gitsigns
        -- 复用全局opts，并绑定当前缓冲区
        local map_opts = { noremap = true, silent = true, nowait = true, buffer = bufnr }

        -- 封装映射函数（简化重复代码）
        local function map(mode, lhs, rhs, custom_opts)
          local final_opts = vim.tbl_extend('force', map_opts, custom_opts or {})
          vim.keymap.set(mode, lhs, rhs, final_opts)
        end

        -- ===================== 1. 导航变更块（hunk） =====================
        -- 下一个变更块（兼容diff模式）
        map('n', ']h', function()
          return vim.wo.diff and ']h' or (vim.schedule(gs.next_hunk) and '<Ignore>')
        end, { desc = 'Git: 跳转到下一个变更块', expr = true })
        -- 上一个变更块（兼容diff模式）
        map('n', '[h', function()
          return vim.wo.diff and '[h' or (vim.schedule(gs.prev_hunk) and '<Ignore>')
        end, { desc = 'Git: 跳转到上一个变更块', expr = true })

        -- ===================== 2. 操作变更块（暂存/撤销） =====================
        -- 暂存当前行/选中块变更
        map('n', '<leader>ghs', gs.stage_hunk, { desc = 'Git: 暂存当前变更块' })
        map('v', '<leader>ghs', function()
          gs.stage_hunk({ vim.fn.line('.'), vim.fn.line('v') })
        end, { desc = 'Git: 暂存选中区域变更块' })
        -- 撤销当前行/选中块变更
        map('n', '<leader>ghr', gs.reset_hunk, { desc = 'Git: 撤销当前变更块' })
        map('v', '<leader>ghr', function()
          gs.reset_hunk({ vim.fn.line('.'), vim.fn.line('v') })
        end, { desc = 'Git: 撤销选中区域变更块' })

        -- 暂存/撤销整个文件
        map('n', '<leader>ghS', gs.stage_buffer, { desc = 'Git: 暂存当前文件所有变更' })
        map('n', '<leader>ghR', gs.reset_buffer, { desc = 'Git: 撤销当前文件所有变更' })
        -- 撤销最近一次暂存
        map('n', '<leader>ghu', gs.undo_stage_hunk, { desc = 'Git: 撤销最近一次暂存操作' })

        -- ===================== 3. 查看变更详情 =====================
        -- 预览当前变更块
        map('n', '<leader>ghp', gs.preview_hunk, { desc = 'Git: 预览当前变更块内容' })
        -- 查看当前行完整提交记录
        map('n', '<leader>ghb', function()
          gs.blame_line({ full = true })
        end, { desc = 'Git: 查看当前行完整提交信息' })
        -- 复制当前行blame信息到剪贴板
        map('n', '<leader>ghB', function()
          local blame = gs.get_blame_line({ full = false })
          vim.fn.setreg('+', blame)
          vim.notify(('已复制Blame信息：%s'):format(blame), vim.log.levels.INFO)
        end, { desc = 'Git: 复制当前行提交信息到剪贴板' })

        -- 对比当前文件与暂存区/上一次提交
        map('n', '<leader>ghd', gs.diffthis, { desc = 'Git: 对比当前文件与暂存区' })
        map('n', '<leader>ghD', function()
          gs.diffthis('~')
        end, { desc = 'Git: 对比当前文件与上一次提交' })

        -- ===================== 4. 功能开关 =====================
        map('n', '<leader>gtb', gs.toggle_current_line_blame, { desc = 'Git: 切换行内提交信息显示' })
        map('n', '<leader>gtd', gs.toggle_deleted, { desc = 'Git: 切换已删除行显示' })
        map('n', '<leader>gts', gs.toggle_signs, { desc = 'Git: 切换变更符号列显示' })

        -- ===================== 5. 额外实用功能 =====================
        -- 快速跳转至变更块起始/结束
        map('n', '<leader>ghh', gs.select_hunk, { desc = 'Git: 选中当前变更块' })
        -- 刷新gitsigns状态（解决部分场景不更新问题）
        map('n', '<leader>ghf', gs.refresh, { desc = 'Git: 刷新变更状态' })

        require('mini.clue').ensure_buf_triggers()
      end,
    })
  end,
}

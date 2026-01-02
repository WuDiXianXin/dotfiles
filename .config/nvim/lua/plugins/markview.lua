return {
  'OXY2DEV/markview.nvim',
  branch = 'main',
  lazy = false,
  dependencies = { 'saghen/blink.cmp' },

  config = function()
    local presets = require('markview.presets')

    require('markview').setup({
      -- 让 markview 在普通 markdown 文件和 Avante 侧边栏都生效
      filetypes = { 'markdown', 'Avante' }, -- ← 这一行是关键！

      markdown = {
        headings = presets.headings.arrowed,
        -- 如果你以后想同时显示箭头 + 编号，可以取消下面这行的注释
        -- headings = vim.tbl_deep_extend("force", presets.headings.arrowed, presets.headings.numbered),

        horizontal_rules = presets.horizontal_rules.arrowed,
        tables = presets.tables.rounded,
        checkboxes = presets.checkboxes.nerd,
      },

      -- 可选：Avante 专用的微调（让代码块、表格在侧边栏里更好看）
      modes = {
        -- 普通模式和插入模式都启用
        { 'n', 'i' },
      },

      -- 可选：如果你觉得 Avante 侧边栏里有些元素太花哨，也可以单独关掉
      -- buffer_options = {
      --   ["Avante"] = {
      --     conceallevel = 2,
      --     concealcursor = "n",
      --   },
      -- },
    })
  end,
}

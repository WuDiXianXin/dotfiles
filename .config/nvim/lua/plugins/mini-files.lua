return {
  {
    'nvim-mini/mini.files',
    version = false,
    config = function()
      require('mini.files').setup({
        windows = {
          preview = true, -- 预览文件内容
          width_focus = 30, -- 聚焦时宽度30列
          width_preview = 80, -- 预览窗口宽度
        },
        options = {
          use_as_default_explorer = true,
        },
      })
    end,
  },
}

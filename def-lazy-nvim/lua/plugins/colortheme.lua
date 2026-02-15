return {
  {
    'folke/tokyonight.nvim',
    branch = 'main',
    lazy = false, -- 非懒加载，启动时立即加载
    priority = 1000, -- 最高优先级，确保先于其他插件加载
    -- opts = {
    --   transparent = true, -- 开启主题自带透明背景
    --   -- styles = {
    --   --   comments = "italic", -- 注释斜体（可选，可删除/修改）
    --   --   keywords = "bold", -- 关键字加粗（可选，可删除/修改）
    --   -- },
    -- },
    -- config 函数：插件加载后执行的专属配置
    config = function(_, opts)
      -- 1. 应用插件 opts 配置
      require('tokyonight').setup(opts)

      -- 2. (options.lua中已开启)强制开启真彩色
      -- vim.opt.termguicolors = true

      -- 3. 加载 tokyonight-night 主题
      vim.cmd([[colorscheme tokyonight-moon]])

      -- -- 4. 增强透明背景：补充主题未覆盖的高亮组
      -- local function setup_transparent()
      --   local transparent_groups = {
      --     -- "Normal", -- 当前光标所在窗口的编辑区域
      --     -- "NormalNC", -- 非当前光标所在窗口的编辑区域
      --     -- "SignColumn", -- 符号列（诊断图标）
      --     -- "LineNr", -- 行号
      --     -- "CursorLineNr", -- 光标行号
      --     'CursorLine', -- 光标行
      --     -- "FloatNormal", -- 浮动窗口内容
      --     -- "FloatBorder", -- 浮动窗口边框
      --     'TabLine', -- 未选中标签（若需要标签栏透明可保留，不需要可删除）
      --     -- "TabLineSel", -- 选中标签（若需要标签栏透明可保留，不需要可删除）
      --     'TabLineFill', -- 标签栏空白区域（若需要标签栏透明可保留，不需要可删除）
      --     'StatusLine', -- 当前窗口底部状态栏（核心：实现底部状态栏透明）
      --     'StatusLineNC', -- 非当前窗口底部状态栏（核心：分屏时状态栏透明统一）
      --   }
      --
      --   for _, group in ipairs(transparent_groups) do
      --     vim.api.nvim_set_hl(0, group, { bg = 'none' })
      --   end
      -- end

      -- 执行透明配置（主题加载后执行，避免被覆盖）
      -- setup_transparent()
    end,
  },
}

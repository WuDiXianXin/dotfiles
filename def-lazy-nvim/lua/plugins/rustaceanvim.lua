return {
  'mrcjkb/rustaceanvim',
  branch = 'master',
  lazy = false,
  config = function()
    vim.g.rustaceanvim = {
      -- dap = false, -- 完全禁用 rustaceanvim 的 DAP 功能
      dap = {
        autoload_configurations = false, -- 只禁用自动加载
      },
    }
  end,
}

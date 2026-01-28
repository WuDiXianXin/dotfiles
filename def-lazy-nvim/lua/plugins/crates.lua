return {
  'saecki/crates.nvim',
  tag = 'stable', -- 推荐：稳定版，更安全
  event = { 'BufRead Cargo.toml' },
  dependencies = { 'nvim-lua/plenary.nvim' },
  opts = {
    autoload = true,
    autoupdate = true,
    loading_indicator = true,
    lsp = {
      enabled = true,
      actions = true,
      completion = true,
      hover = true,
    },
  },
  config = function(_, opts)
    require('crates').setup(opts)

    local crates = require('crates')
    vim.keymap.set('n', '<leader>cu', crates.upgrade_all_crates, { desc = 'Crates: 升级所有依赖' })
    vim.keymap.set('n', '<leader>cU', crates.update_all_crates, { desc = 'Crates: 更新所有依赖' })
    vim.keymap.set('n', '<leader>ch', crates.show_popup, { desc = 'Crates: 显示版本/特性弹窗' })
    vim.keymap.set('n', '<leader>cv', crates.show_versions_popup, { desc = 'Crates: 显示版本弹窗' })
    vim.keymap.set('n', '<leader>cf', crates.show_features_popup, { desc = 'Crates: 显示特性弹窗' })
    vim.keymap.set('n', '<leader>cd', crates.open_documentation, { desc = 'Crates: 打开文档' })
    vim.keymap.set('n', '<leader>cr', crates.reload, { desc = 'Crates: 重新加载缓存' })
    require('mini.clue').ensure_buf_triggers()
  end,
}

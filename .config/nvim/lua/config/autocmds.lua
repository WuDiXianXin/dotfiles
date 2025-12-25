-- 1. 创建全局 autocmd 组
local global_autocmd_group =
  vim.api.nvim_create_augroup('global_autocmd_group', { clear = true })

-- 2. 复制文本后高亮提示
vim.api.nvim_create_autocmd('TextYankPost', {
  group = global_autocmd_group,
  desc = 'Highlight text after copying (yank)',
  callback = function()
    vim.hl.on_yank({ higroup = 'IncSearch', timeout = 300 }) -- 300ms 高亮，颜色同搜索
  end,
})

-- 3. 保存前自动格式化
vim.api.nvim_create_autocmd('BufWritePre', {
  group = global_autocmd_group,
  desc = 'Auto format code with LSP before saving file',
  pattern = '*',
  callback = function()
    pcall(vim.lsp.buf.format, {
      async = false, -- 同步格式化（保存前完成）
      timeout_ms = 1000, -- 新增：超时1s，避免卡住
    })
  end,
})

-- 4. 打开文件自动恢复上次光标位置 + 展开折叠
vim.api.nvim_create_autocmd({ 'BufReadPost' }, {
  group = global_autocmd_group,
  pattern = { '*' },
  callback = function()
    vim.api.nvim_exec2('silent! normal! g`"zv', { output = false })
  end,
})

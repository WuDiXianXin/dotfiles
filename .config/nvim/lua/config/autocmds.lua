local map = function(mode, lhs, rhs, desc, extra_opts)
  local options = vim.tbl_extend('force', { noremap = true, silent = true, nowait = true }, extra_opts or {})
  if desc then
    options.desc = desc
  end
  vim.keymap.set(mode, lhs, rhs, options)
end

local nmap = function(lhs, rhs, desc, opts)
  map('n', lhs, rhs, desc, opts)
end

vim.api.nvim_create_autocmd('BufEnter', {
  callback = function()
    -- 禁用新行自动延续注释格式
    vim.opt_local.formatoptions:remove({ 'c', 'r', 'o' })

    nmap(' ', '<Nop>', 'Leader')
    nmap('<CR>', '<Nop>', '禁用回车默认功能')

    nmap('<leader>!', ':!', '快速进入 :!')
    nmap('<leader>;', ':!', '快速进入 :!')

    nmap('<leader>j', '*``cgn', '替换光标所在单词（按 . 继续下一个）')
    nmap('<leader>r', ':%s/', '快速提供替换命令')

    map({ 'i', 't' }, 'kj', '<Esc>', '快速退出插入模式')
    map({ 'i', 't' }, 'jk', '<Esc>', '快速退出插入模式')

    nmap('<leader>lf', vim.lsp.buf.format, '格式化当前文件')
  end,
})

vim.api.nvim_create_autocmd('LspAttach', {
  callback = function()
    vim.diagnostic.config({
      float = {
        border = 'rounded',
        source = 'if_many',
      },
      virtual_lines = {
        current_line = true, -- 虚行显示 lsp 提示
      },
    })
    nmap('<leader>qq', vim.diagnostic.setloclist, '所有诊断填充到位置列表')
    nmap('<leader>ql', function()
      local winid = vim.fn.getloclist(0, { winid = 0 }).winid
      if winid == 0 then
        vim.cmd('lopen')
      else
        vim.cmd('lclose')
      end
    end, '打开/关闭位置列表')
  end,
})

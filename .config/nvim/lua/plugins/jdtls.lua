return {
  'mfussenegger/nvim-jdtls',
  ft = { 'java' }, -- 只在 Java 文件加载
  config = function()
    -- 自动启动 jdtls（与 lspconfig 集成）
    local jdtls = require('jdtls')

    jdtls.start_or_attach(vim.tbl_extend('force', vim.lsp.jdtls.config(), {
      settings = {
        java = {
          configuration = {
            runtimes = { -- 如果多 JDK
              { name = "JavaSE-17", path = "/path/to/jdk17" },
            },
          },
        },
      },
    }))

    vim.api.nvim_create_autocmd('FileType', {
      pattern = 'java',
      callback = function()
        jdtls.start_or_attach(vim.lsp.jdtls.config())
      end,
    })
  end,
}

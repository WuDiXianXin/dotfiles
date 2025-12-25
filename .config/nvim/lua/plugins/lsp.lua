return {
  {
    'neovim/nvim-lspconfig',
    branch = 'master',
    event = { 'BufReadPre', 'BufNewFile' },
    dependencies = {
      { 'SmiteshP/nvim-navic', branch = 'master' }, -- 面包屑
    },
    config = function()
      local navic = require("nvim-navic")

      local on_attach = function(client, bufnr)
        if client.server_capabilities.documentSymbolProvider then
          navic.attach(client, bufnr)
        end
      end

      -- ==================== LSP 配置 ====================

      -- 1. Lua LSP
      vim.lsp.config('lua_ls', {
        on_attach = on_attach,
        settings = {
          Lua = {
            runtime = {
              version = 'LuaJIT',
              path = (function()
                local runtime_path = vim.split(package.path, ';')
                table.insert(runtime_path, 'lua/?.lua')
                table.insert(runtime_path, 'lua/?/init.lua')
                return runtime_path
              end)(),
            },
            diagnostics = { globals = { 'vim' } },
            workspace = {
              checkThirdParty = false,
              library = {
                vim.env.VIMRUNTIME,
                '${3rd}/luv/library',
              },
            },
            telemetry = { enable = false },
          },
        },
      })

      -- 2. Rust Analyzer
      vim.lsp.config('rust_analyzer', {
        on_attach = on_attach,
        settings = {
          ['rust-analyzer'] = {
            check = { command = 'clippy' },
            cargo = { allFeatures = true },
            procMacro = { enable = true },
          },
        },
      })

      -- 3. Bash LSP
      vim.lsp.config('bashls', {
        on_attach = on_attach,
      })

      -- 4. Fish LSP
      vim.lsp.config('fish_lsp', {
        on_attach = on_attach,
      })

      -- 5. clangd
      vim.lsp.config('clangd', {
        on_attach = on_attach,
        cmd = {
          'clangd',
          '--background-index',
          '--clang-tidy',            -- 可选：启用 clang-tidy 检查
          '--header-insertion=iwyu', -- 智能头文件插入
          '--completion-style=detailed',
          '--function-arg-placeholders',
          '--fallback-style=llvm',
        },
        init_options = {
          usePlaceholders = true,
          completeUnimported = true,
          clangdFileStatus = true,
        },
      })

      -- 6. Python: pyright（推荐，轻量、类型检查强）
      vim.lsp.config('pyright', {
        on_attach = on_attach,
        -- 更推荐放在 root_dir 检测里自动识别 venv
        root_dir = require('lspconfig.util').root_pattern('pyproject.toml', 'setup.py', '.git'),
        settings = {
          python = {
            analysis = {
              autoSearchPaths = true,
              useLibraryCodeForTypes = true,
              diagnosticMode = 'workspace', -- 或 'openFilesOnly'
            },
          },
        },
      })

      -- 7. Java: jdtls（Eclipse JDT Language Server，功能最全）
      vim.lsp.config('jdtls', {
        on_attach = on_attach,
      })

      -- ==================== 启用所有 LSP ====================
      vim.lsp.enable({
        'lua_ls',
        'rust_analyzer',
        'bashls',
        'fish_lsp',
        'clangd',
        'pyright',
        'jdtls',
      })
    end,
  },

  {
    'SmiteshP/nvim-navic',
    branch = 'master',
    event = 'LspAttach',
    opts = {
      highlight = true,
      separator = ' > ',
      depth_limit = 5,
      icons = {},
      lazy_update_context = true,
      safe_output = true,
    },
  },
}

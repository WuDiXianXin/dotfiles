return {
  {
    'neovim/nvim-lspconfig',
    branch = 'master',
    event = { 'BufReadPre', 'BufNewFile' },
    dependencies = {
      { 'SmiteshP/nvim-navic', branch = 'master' }, -- 面包屑
    },
    config = function()
      local navic = require('nvim-navic')

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
      -- vim.lsp.config('rust_analyzer', {
      --   on_attach = on_attach,
      --   settings = {
      --     ['rust-analyzer'] = {
      --       check = { command = 'clippy' },
      --       cargo = { allFeatures = true },
      --       procMacro = { enable = true },
      --     },
      --   },
      -- })

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
          '--clang-tidy', -- 可选：启用 clang-tidy 检查
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

      -- 6. Python: pylyzer（快速静态代码分析 & 语言服务器，替代pyright）
      vim.lsp.config('pylyzer', {
        on_attach = on_attach,

        -- pylyzer 核心命令：启动语言服务器模式
        cmd = { 'pylyzer', '--server' },
        -- 仅对python文件生效
        filetypes = { 'python' },
        -- pylyzer 运行环境配置：指定Erg依赖的路径
        cmd_env = {
          ERG_PATH = vim.env.ERG_PATH or vim.fs.joinpath(vim.uv.os_homedir(), '.erg'),
        },
        -- pylyzer 功能配置
        settings = {
          python = {
            diagnostics = true, -- 启用代码诊断（语法/逻辑错误检测）
            inlayHints = true, -- 启用内嵌提示（如类型提示、参数名提示）
            smartCompletion = true, -- 启用智能补全
            checkOnType = false, -- 关闭输入时实时检查（可根据需求改为true，注意性能消耗）
            -- 保留原pyright中实用的分析配置（pylyzer兼容部分类似配置）
            analysis = {
              autoSearchPaths = true,
              useLibraryCodeForTypes = true,
              diagnosticMode = 'workspace', -- 或 'openFilesOnly'（仅检查打开的文件，更快）
            },
          },
        },
      })

      -- ==================== 启用所有 LSP ====================
      vim.lsp.enable({
        'lua_ls',
        -- 'rust_analyzer',
        'bashls',
        'fish_lsp',
        'clangd',
        'pylyzer',
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
      depth_limit = 3,
      icons = {},
      lazy_update_context = true,
      safe_output = true,
    },
  },
}

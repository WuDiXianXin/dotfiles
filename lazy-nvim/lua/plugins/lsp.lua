return {
  -- 覆盖 nvim-lspconfig 的 opts 配置，专门修改 lua_ls
  'neovim/nvim-lspconfig',
  opts = {
    servers = {
      -- 针对 lua_ls 进行配置覆盖
      lua_ls = {
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
      },
    },
  },
}

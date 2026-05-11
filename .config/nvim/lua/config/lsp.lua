-- ================== 诊断 ==================

-- 诊断
vim.diagnostic.config({
    virtual_text = true, -- 在行尾显示错误信息
    signs = {
        text = {
            [vim.diagnostic.severity.ERROR] = ' ',
            [vim.diagnostic.severity.WARN] = ' ',
            [vim.diagnostic.severity.INFO] = ' ',
            [vim.diagnostic.severity.HINT] = ' ',
        },
        severity = { min = vim.diagnostic.severity.HINT },
    },
    underline = true,
    update_in_insert = false, -- 插入模式下不实时更新
    severity_sort = true, -- 按严重程度排序
    float = { -- 悬浮窗口样式
        source = 'always',
        border = 'rounded',
        header = '',
    },
})

-- 内联提示（Inline Hint） - 强烈推荐打开
vim.lsp.inlay_hint.enable(true) -- Neovim 0.10+

-- 自动悬浮窗口（鼠标悬停或光标停留时显示文档）
vim.api.nvim_create_autocmd('CursorHold', {
    callback = function()
        vim.diagnostic.open_float(nil, { focusable = false })
    end,
})

-- ================== LSP 配置 ==================
-- lua
vim.lsp.config('lua_ls', {
    cmd = { 'lua-language-server' },
    filetypes = { 'lua' },
    root_markers = { '.luarc.json', '.luarc.jsonc', '.git' },

    settings = {
        Lua = {
            runtime = {
                version = 'LuaJIT',
                path = {
                    'lua/?.lua',
                    'lua/?/init.lua',
                },
            },

            diagnostics = {
                -- globals = { "vim", "describe", "it", "before_each", "after_each", "pending" },
                globals = { 'vim' },
            },

            workspace = {
                checkThirdParty = false,
                library = {
                    vim.env.VIMRUNTIME,
                    '${3rd}/luv/library',
                },
            },

            telemetry = { enable = false },

            hint = { -- Inline Hint
                enable = true,
                arrayIndex = 'Auto',
                setType = true,
                paramName = 'All',
                paramType = true,
                await = true,
            },
        },
    },
})

-- clangd
vim.lsp.config('clangd', {
    cmd = {
        'clangd',
        '--background-index',
        '--clang-tidy',
        '--header-insertion=iwyu',
        '--completion-style=detailed',
        '--all-scopes-completion',
        '--pch-storage=memory',
        '--enable-config',
        '--fallback-style=llvm',
    },
    init_options = {
        usePlaceholders = true,
        completeUnimported = true,
        clangdFileStatus = true,
    },

    filetypes = { 'c', 'cpp', 'objc', 'objcpp' },

    root_markers = {
        '.clangd',
        'compile_commands.json',
        'compile_flags.txt',
        '.git',
        'CMakeLists.txt',
        'MakeFile',
        'meson.build',
    },

    capabilities = {
        textDocument = {
            semanticTokens = { multilineTokenSupport = true },
            inlayHint = {
                dynamicRegistration = true,
            },
            foldingRange = { -- 按行折叠
                dynamicRegistration = false,
                lineFoldingOnly = true,
            },
        },
        offsetEncoding = { 'utf-8', 'utf-16' },
    },

    settings = {
        clangd = {
            fallbackFlags = { '-std=c++23' },
            index = {
                onChange = true, -- 文件修改时立即更新索引
            },
            completion = {
                insertInclude = true, -- 自动插入 #include
            },
            inlayHints = {
                enabled = true, -- 总开关
                parameterNames = true, -- 参数名称提示
                deducedTypes = true, -- 推导类型提示
                typeElaborations = true, -- 更详细的类型提示
                designators = true, -- 聚合初始化提示
                blockEnd = false, -- 是否显示 } 后的提示（一般关掉）
            },
        },
    },
})

vim.lsp.enable({ 'lua_ls', 'clangd' })

-- ==================== 诊断 ====================
local severity = vim.diagnostic.severity
vim.diagnostic.config({
    virtual_text = false, -- 在行尾显示错误信息
    signs = {
        text = {
            [severity.ERROR] = ' ',
            [severity.WARN] = ' ',
            [severity.INFO] = ' ',
            [severity.HINT] = ' ',
        },
        severity = { min = severity.HINT },
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

-- ================== LSP 配置 ==================
-- lua_ls 配置
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

-- clangd 配置
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
            -- semanticTokens = { multilineTokenSupport = true },
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
            -- fallbackFlags = { '-std=c++23' },
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

-- ==================== autocmd ====================

local autocmd = vim.api.nvim_create_autocmd

autocmd('LspAttach', {
    group = 'LSP',
    desc = 'LSP 快捷键',
    callback = function()
        local nmap = require('utils.keymap').nmap

        nmap('<leader>q', vim.diagnostic.setloclist, '所有诊断填充到位置列表')
        nmap('<leader>l', function()
            local winid = vim.fn.getloclist(0, { winid = 0 }).winid
            if winid == 0 then
                vim.cmd('lopen')
            else
                vim.cmd('lclose')
            end
        end, '打开/关闭位置列表')

        local buf = vim.lsp.buf
        nmap('K', buf.hover, '显示悬浮文档')
        nmap('grd', buf.definition, '跳转定义')
        nmap('grD', buf.declaration, '跳转声明')
        nmap('grr', buf.references, '查找所有引用')
        nmap('gri', buf.implementation, '跳转实现')
        nmap('grn', buf.rename, '全局重命名')
        nmap('gra', buf.code_action, '代码动作')
        nmap('grt', buf.type_definition, '跳转类型定义')
        nmap('<leader>lf', buf.format, '格式化当前文件')
    end,
})

autocmd('LspAttach', {
    group = 'LSP',
    desc = '禁用所有 lsp 自带的语法高亮',
    callback = function(ev)
        local client = vim.lsp.get_client_by_id(ev.data.client_id)
        if client and client.server_capabilities.semanticTokensProvider then
            client.server_capabilities.semanticTokensProvider = nil
        end
    end,
})

autocmd('CursorHold', {
    group = 'LSP',
    desc = '鼠标悬停或光标停留时显示诊断信息',
    callback = function()
        vim.diagnostic.open_float(nil, { focusable = false })
    end,
})

autocmd('FileType', {
    group = 'LSP',
    desc = '启动 lua LSP 服务',
    pattern = { 'lua' },
    callback = function()
        vim.lsp.enable({ 'lua_ls' })
    end,
})

autocmd('FileType', {
    group = 'LSP',
    desc = '启动 clangd LSP 服务',
    pattern = { 'c', 'cpp' },
    callback = function()
        vim.lsp.enable({ 'clangd' })
    end,
})

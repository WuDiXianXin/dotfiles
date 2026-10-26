-- ============================================================================
-- autocmds.lua - Neovim 自动命令配置
-- ============================================================================
-- 本文件集中管理所有自动命令（autocmd），按功能分组：
--   General        - 通用编辑体验（复制高亮、光标恢复等）
--   LSP            - LSP 相关（预留，后续添加）
--   UI             - 界面显示相关（默认注释，按需启用）
--   SensitiveFiles - 敏感文件保护（禁用持久化撤销/备份）
-- ============================================================================

local api = vim.api
local autocmd = api.nvim_create_autocmd
local augroup = api.nvim_create_augroup

-- ============================================================================
-- 分组定义
-- ============================================================================

-- 通用编辑体验组
augroup('General', { clear = true })

-- LSP 相关组（预留，添加 LSP 自动命令时使用）
augroup('LSP', { clear = true })

-- 敏感文件保护组
augroup('SensitiveFiles', { clear = true })

-- ============================================================================
-- General 组：通用编辑体验
-- ============================================================================

-- 复制文本后短暂高亮，提供视觉反馈（300ms，颜色同搜索高亮）
autocmd('TextYankPost', {
    group = 'General',
    desc = '复制文本后高亮提示',
    callback = function()
        vim.hl.on_yank({ higroup = 'IncSearch', timeout = 300 })
        -- vim.hl.hl_op({ higroup = 'IncSearch', timeout = 300 })
    end,
})

-- 打开文件时自动恢复上次光标位置，并展开光标所在折叠
autocmd('BufReadPost', {
    group = 'General',
    desc = '打开文件自动恢复上次光标位置 + 展开折叠',
    callback = function()
        -- g`" 跳转到上次编辑位置；zv 展开折叠；
        -- silent! 避免文件没有上次光标 mark 时报错
        api.nvim_exec2('silent! normal! g`"zv', { output = false })
    end,
})

-- 禁用新行自动延续注释格式（按需启用）
-- autocmd('BufEnter', {
--     group = 'General',
--     desc = '禁用新行自动延续注释格式',
--     callback = function()
--         vim.opt_local.formatoptions:remove({ 'c', 'r', 'o' })
--     end,
-- })

-- ============================================================================
-- SensitiveFiles 组：敏感文件保护
-- ============================================================================
-- 当打开敏感文件（sudoedit 临时副本、密钥、.env、SSH 私钥等）时，
-- 在本地缓冲区禁用持久化撤销和写入备份，防止敏感内容落盘。
-- 使用 opt_local 仅影响当前缓冲区，不影响全局配置。
-- ============================================================================

autocmd({ 'BufRead', 'BufNewFile' }, {
    group = 'SensitiveFiles',
    desc = '敏感文件禁用持久化撤销/备份记录',
    pattern = {
        -- 临时文件路径：sudoedit 的默认位置和常见备选
        '/var/tmp/*',
        '/tmp/*',
        '/dev/shm/*',

        -- 敏感扩展名：证书与密钥库
        '*.pem',
        '*.key',
        '*.p12',
        '*.pfx',
        '*.jks',
        '*.keystore',

        -- 环境变量文件（API 密钥高发区）
        '.env',
        '.env.*',

        -- SSH 目录（** 可递归匹配多级目录，如 ~/.ssh/id_rsa）
        '**/.ssh/*',

        -- 系统级敏感文件（注意：普通用户可能无读取权限，autocmd 未必触发）
        '*/etc/shadow',
        '*/etc/sudoers',
        '*/etc/gshadow',

        -- 可选兜底：匹配所有点文件（范围较广，按需启用）
        -- '.*',
    },
    callback = function()
        vim.opt_local.undofile = false -- 不写入持久化撤销历史
        vim.opt_local.writebackup = false -- 不保留写入失败时的临时备份
        vim.notify('不保留该文件任何信息：关闭撤销记录和临时备份', vim.log.levels.INFO)
    end,
})

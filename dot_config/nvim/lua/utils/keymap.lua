-- ==================== 全局键位映射工具函数 ====================
local M = {}

-- 全局 map（非 buffer）
local map = function(mode, lhs, rhs, desc, extra_opts)
    local options = vim.tbl_extend('force', {
        noremap = true,
        silent = true,
        nowait = true,
    }, extra_opts or {})

    if desc then
        options.desc = desc
    end

    vim.keymap.set(mode, lhs, rhs, options)
end

M.map = map
M.nmap = function(lhs, rhs, desc, opts)
    map('n', lhs, rhs, desc, opts)
end
M.imap = function(lhs, rhs, desc, opts)
    map('i', lhs, rhs, desc, opts)
end
M.vmap = function(lhs, rhs, desc, opts)
    map('v', lhs, rhs, desc, opts)
end
M.xmap = function(lhs, rhs, desc, opts)
    map('x', lhs, rhs, desc, opts)
end
M.nxmap = function(lhs, rhs, desc, opts)
    map({ 'n', 'x' }, lhs, rhs, desc, opts)
end

-- ==================== Buffer 专用 ====================
M.bufmap = function(bufnr)
    return {
        map = function(mode, lhs, rhs, desc, opts)
            local o = vim.tbl_extend('force', { buffer = bufnr }, opts or {})
            M.map(mode, lhs, rhs, desc, o)
        end,

        nmap = function(lhs, rhs, desc, opts)
            local o = vim.tbl_extend('force', { buffer = bufnr }, opts or {})
            M.nmap(lhs, rhs, desc, o)
        end,

        vmap = function(lhs, rhs, desc, opts)
            local o = vim.tbl_extend('force', { buffer = bufnr }, opts or {})
            M.vmap(lhs, rhs, desc, o)
        end,
    }
end

return M

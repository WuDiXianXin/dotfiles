vim.pack.add({
    {
        src = 'https://github.com/monkoose/neocodeium',
        branch = 'main',
    },
})
local neocodeium = require('neocodeium')
neocodeium.setup({
    manual = false,
    show_label = true,
    debounce = false,
    max_lines = 10000,
    silent = false,
    disable_in_special_buftypes = true,
    filter = function()
        return not require('blink.cmp').is_visible()
    end,
    log_level = 'warn',
    single_line = {
        enabled = false,
        label = '...', -- 表示存在多行建议的标签
    },
    filetypes = {
        help = false,
        gitcommit = false,
        gitrebase = false,
        ['.'] = false,
    },
    -- 用于为 Windsurf Chat 检测工作区根目录的目录和文件列表
    root_dir = {
        '.bzr',
        '.git',
        '.hg',
        '.svn',
        '_FOSSIL_',
        'package.json',
        'pom.xml',
        'Cargo.toml',
        'CMakeLists.txt',
        'Makefile',
        'configure',
        'meson.build',
        'compile_commands.json',
    },
})

vim.keymap.set('i', '<A-a>', neocodeium.accept)
vim.keymap.set('i', '<A-l>', neocodeium.accept_line)
-- 下一个建议
vim.keymap.set('i', '<A-n>', neocodeium.cycle_or_complete)

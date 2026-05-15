vim.pack.add({
    {
        src = 'https://github.com/OXY2DEV/markview.nvim',
        branch = 'main',
    },
})

local presets = require('markview.presets')

require('markview').setup({
    markdown = {
        headings = presets.headings.arrowed,
        -- 如果你以后想同时显示箭头 + 编号，可以取消下面这行的注释
        -- headings = vim.tbl_deep_extend("force", presets.headings.arrowed, presets.headings.numbered),

        horizontal_rules = presets.horizontal_rules.arrowed,
        tables = presets.tables.rounded,
        checkboxes = presets.checkboxes.nerd,
    },
})

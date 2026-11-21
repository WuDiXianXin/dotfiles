return {
    {
        'mason-org/mason.nvim',
        build = ':MasonUpdate',
        opts = {},
    },
    -- {
    --     'WhoIsSethDaniel/mason-tool-installer.nvim',
    --     dependencies = { 'mason-org/mason.nvim' },
    --     opts = {
    --         ensure_installed = {
    --             'codelldb',
    --         },
    --         auto_update = false,
    --         run_on_start = true,
    --     },
    -- }
}

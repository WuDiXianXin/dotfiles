return {
    {
        'igorlfs/nvim-dap-view',
        lazy = true,
        dependencies = {
            'rcarriga/nvim-dap-ui',
            'nvim-neotest/nvim-nio',
        },
        config = function()
            require('dap-view').setup({
                winbar = {
                    show_keymap_hints = false,
                    sections = {
                        'watches',
                        'scopes',
                        'exceptions',
                        'repl',
                        'sessions',
                        'breakpoints',
                        'threads',
                        'console',
                    },
                    default_section = 'threads',
                    controls = {
                        enabled = true,
                        position = 'left',
                    },
                },
                switchbuf = 'usetab,newtab',
                windows = {
                    size = 0.6,
                    position = 'right',
                    terminal = {
                        size = 0.5,
                        position = 'right',
                    },
                },
            })
        end,
    },
}

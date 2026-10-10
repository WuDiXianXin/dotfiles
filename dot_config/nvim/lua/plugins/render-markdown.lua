return {
    {
        'MeanderingProgrammer/render-markdown.nvim',
        ft = 'markdown',
        config = function()
            require('render-markdown').setup({
                file_types = { 'markdown' },
                sign = { enabled = false },
                heading = {
                    position = 'inline',
                    width = 'block',
                    backgrounds = {
                        'RenderMarkdownH1',
                        'RenderMarkdownH2',
                        'RenderMarkdownH3',
                        'RenderMarkdownH4',
                        'RenderMarkdownH5',
                        'RenderMarkdownH6',
                    },
                },
                code = {
                    language_border = '',
                    language_left = '',
                    language_right = '',
                    width = 'block',
                    left_pad = 1,
                    right_pad = 1,
                },
                checkbox = {
                    unchecked = { icon = '✘ ' },
                    checked = { icon = '✔ ', scope_highlight = '@markup.strikethrough' },
                    custom = {
                        important = {
                            raw = '[~]',
                            rendered = '󰓎 ',
                            highlight = 'DiagnosticWarn',
                        },
                    },
                },
                pipe_table = { preset = 'round' },
            })

            require('utils.keymap').nmap(
                '<leader>m',
                '<cmd>RenderMarkdown toggle<CR>',
                '只切换当前 Markdown 文件的渲染'
            )
        end,
    },
}

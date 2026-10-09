return {
    {
        "lervag/vimtex",
        ft = "tex",

        init = function()
            vim.g.vimtex_view_method = "zathura"
            vim.g.vimtex_compiler_method = "latexmk"
            vim.g.vimtex_quickfix_mode = 0
            vim.g.vimtex_mappings_enabled = 1
        end,

        keys = {
            {
                "<leader>lc",
                "<cmd>VimtexCompile<cr>",
                desc = "LaTeX compile",
            },
            {
                "<leader>lv",
                "<cmd>VimtexView<cr>",
                desc = "LaTeX view PDF",
            },
            {
                "<leader>lq",
                "<cmd>VimtexStop<cr>",
                desc = "LaTeX stop compiler",
            },
            {
                "<leader>le",
                "<cmd>VimtexErrors<cr>",
                desc = "LaTeX errors",
            },
        },
    },
}

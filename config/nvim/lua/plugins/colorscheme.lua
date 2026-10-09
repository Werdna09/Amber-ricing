return {
    {
        "sainnhe/sonokai",
        lazy = false,
        priority = 1000,

        config = function()
            vim.g.sonokai_style = "andromeda"
            vim.g.sonokai_better_performance = 1
            vim.g.sonokai_enable_italic = 1
            vim.g.sonokai_disable_italic_comment = 0
            vim.g.sonokai_transparent_background = 0
            vim.g.sonokai_float_style = "dim"
            vim.g.sonokai_menu_selection_background = "blue"
            vim.g.sonokai_diagnostic_virtual_text = "grey"

            vim.cmd.colorscheme("sonokai")

            vim.api.nvim_set_hl(0, "WinSeparator", { fg = "#393e53" })
            vim.api.nvim_set_hl(0, "FloatBorder", { fg = "#6dcae8", bg = "#252630" })
            vim.api.nvim_set_hl(0, "CursorLineNr", { fg = "#bb97ee", bold = true })
        end,
    },
}

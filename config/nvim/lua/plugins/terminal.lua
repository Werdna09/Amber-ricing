return {
    {
        "akinsho/toggleterm.nvim",
        version = "*",

        keys = {
            {
                "<leader>tt",
                "<cmd>ToggleTerm direction=float<cr>",
                desc = "Terminal",
            },
        },

        opts = {
            direction = "float",
            start_in_insert = true,
            persist_size = true,
            shade_terminals = false,

            float_opts = {
                border = "curved",

                width = function()
                    return math.floor(vim.o.columns * 0.82)
                end,

                height = function()
                    return math.floor(vim.o.lines * 0.78)
                end,
            },
        },
    },
}

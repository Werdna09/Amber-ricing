return {
    {
        "stevearc/oil.nvim",
        cmd = "Oil",
        dependencies = {
            "nvim-tree/nvim-web-devicons",
        },

        keys = {
            {
                "<leader>e",
                "<cmd>Oil<cr>",
                desc = "File browser",
            },
            {
                "-",
                "<cmd>Oil<cr>",
                desc = "Open parent directory",
            },
        },

        opts = {
            default_file_explorer = true,
            skip_confirm_for_simple_edits = true,

            columns = {
                "icon",
            },

            view_options = {
                show_hidden = true,
            },

            float = {
                padding = 4,
                border = "rounded",
            },
        },
    },
}

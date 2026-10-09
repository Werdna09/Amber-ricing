return {
    {
        "nvim-telescope/telescope.nvim",
        cmd = "Telescope",

        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-tree/nvim-web-devicons",
        },

        keys = {
            {
                "<leader>ff",
                function()
                    require("telescope.builtin").find_files({
                        hidden = true,
                    })
                end,
                desc = "Find files",
            },

            {
                "<leader>fg",
                function()
                    require("telescope.builtin").live_grep({
                        additional_args = function()
                            return {
                                "--hidden",
                                "--glob",
                                "!.git/*",
                            }
                        end,
                    })
                end,
                desc = "Find text",
            },

            {
                "<leader>fb",
                function()
                    require("telescope.builtin").buffers()
                end,
                desc = "Find buffers",
            },

            {
                "<leader>fr",
                function()
                    require("telescope.builtin").oldfiles()
                end,
                desc = "Recent files",
            },

            {
                "<leader>fh",
                function()
                    require("telescope.builtin").help_tags()
                end,
                desc = "Find help",
            },

            {
                "<leader>gs",
                function()
                    require("telescope.builtin").git_status()
                end,
                desc = "Git status",
            },

            {
                "<leader>gb",
                function()
                    require("telescope.builtin").git_branches()
                end,
                desc = "Git branches",
            },

            {
                "<leader>gc",
                function()
                    require("telescope.builtin").git_commits()
                end,
                desc = "Git commits",
            },
        },

        config = function()
            require("telescope").setup({
                defaults = {
                    prompt_prefix = "   ",
                    selection_caret = "❯ ",
                    path_display = { "smart" },
                    sorting_strategy = "ascending",

                    layout_config = {
                        horizontal = {
                            prompt_position = "top",
                            preview_width = 0.55,
                        },
                        width = 0.90,
                        height = 0.85,
                    },

                    border = true,
                },
            })
        end,
    },
}

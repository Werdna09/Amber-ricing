return {
    {
        "nvim-tree/nvim-web-devicons",
        lazy = true,
    },

    {
        "nvim-lualine/lualine.nvim",
        event = "VeryLazy",
        dependencies = {
            "nvim-tree/nvim-web-devicons",
        },

        config = function()
            local crylia = {
                normal = {
                    a = { fg = "#181a1c", bg = "#bb97ee", gui = "bold" },
                    b = { fg = "#e1e3e4", bg = "#333648" },
                    c = { fg = "#e1e3e4", bg = "#2b2d3a" },
                },

                insert = {
                    a = { fg = "#181a1c", bg = "#9ed06c", gui = "bold" },
                },

                visual = {
                    a = { fg = "#181a1c", bg = "#edc763", gui = "bold" },
                },

                replace = {
                    a = { fg = "#181a1c", bg = "#fb617e", gui = "bold" },
                },

                command = {
                    a = { fg = "#181a1c", bg = "#6dcae8", gui = "bold" },
                },

                inactive = {
                    a = { fg = "#7e8294", bg = "#252630" },
                    b = { fg = "#7e8294", bg = "#252630" },
                    c = { fg = "#7e8294", bg = "#252630" },
                },
            }

            require("lualine").setup({
                options = {
                    theme = crylia,
                    globalstatus = true,
                    section_separators = { left = "", right = "" },
                    component_separators = { left = "│", right = "│" },
                },

                sections = {
                    lualine_a = { "mode" },
                    lualine_b = { "branch", "diff" },
                    lualine_c = {
                        {
                            "filename",
                            path = 1,
                            symbols = {
                                modified = " ●",
                                readonly = " ",
                                unnamed = "[No Name]",
                            },
                        },
                    },
                    lualine_x = { "diagnostics", "encoding", "filetype" },
                    lualine_y = { "progress" },
                    lualine_z = { "location" },
                },
            })
        end,
    },

    {
        "akinsho/bufferline.nvim",
        version = "*",
        event = "VeryLazy",
        dependencies = {
            "nvim-tree/nvim-web-devicons",
        },

        opts = {
            options = {
                mode = "buffers",
                diagnostics = "nvim_lsp",
                separator_style = "thin",
                show_buffer_close_icons = false,
                show_close_icon = false,
                always_show_bufferline = true,

                indicator = {
                    style = "icon",
                    icon = "▎",
                },
            },

            highlights = {
                indicator_selected = {
                    fg = "#6dcae8",
                },
                buffer_selected = {
                    fg = "#e1e3e4",
                    bold = true,
                    italic = false,
                },
            },
        },
    },

    {
        "folke/which-key.nvim",
        event = "VeryLazy",

        opts = {
            preset = "modern",
            delay = 350,
            win = {
                border = "rounded",
            },
        },

        keys = {
            {
                "<leader>?",
                function()
                    require("which-key").show({ global = false })
                end,
                desc = "Buffer keymaps",
            },
        },
    },
}

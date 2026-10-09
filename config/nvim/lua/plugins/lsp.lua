return {
    {
        "mason-org/mason-lspconfig.nvim",

        dependencies = {
            {
                "mason-org/mason.nvim",
                opts = {
                    ui = {
                        border = "rounded",
                    },
                },
            },

            "neovim/nvim-lspconfig",
            "hrsh7th/cmp-nvim-lsp",
        },

        config = function()
            local capabilities =
                require("cmp_nvim_lsp").default_capabilities()

            vim.lsp.config("*", {
                capabilities = capabilities,
            })

            vim.lsp.config("lua_ls", {
                settings = {
                    Lua = {
                        runtime = {
                            version = "LuaJIT",
                        },

                        diagnostics = {
                            globals = {
                                "vim",
                            },
                        },

                        workspace = {
                            checkThirdParty = false,
                            library = vim.api.nvim_get_runtime_file("", true),
                        },
                    },
                },
            })

            vim.lsp.config("clangd", {
                cmd = {
                    "clangd",
                    "--background-index",
                    "--clang-tidy",
                    "--completion-style=detailed",
                },
            })

            vim.lsp.config("basedpyright", {
                settings = {
                    basedpyright = {
                        analysis = {
                            typeCheckingMode = "standard",
                        },
                    },
                },
            })

            require("mason-lspconfig").setup({
                ensure_installed = {
                    "bashls",
                    "basedpyright",
                    "clangd",
                    "cssls",
                    "html",
                    "jsonls",
                    "lua_ls",
                    "texlab",
                    "ts_ls",
                },

                automatic_enable = true,
            })

            vim.diagnostic.config({
                severity_sort = true,
                underline = true,
                signs = true,

                virtual_text = {
                    spacing = 3,
                    prefix = "●",
                },

                float = {
                    border = "rounded",
                    source = true,
                },
            })

            vim.api.nvim_create_autocmd("LspAttach", {
                group = vim.api.nvim_create_augroup(
                    "CryliaLsp",
                    { clear = true }
                ),

                callback = function(args)
                    local opts = {
                        buffer = args.buf,
                        silent = true,
                    }

                    local function map(lhs, rhs, desc)
                        vim.keymap.set(
                            "n",
                            lhs,
                            rhs,
                            vim.tbl_extend(
                                "force",
                                opts,
                                { desc = desc }
                            )
                        )
                    end

                    map("gd", vim.lsp.buf.definition, "Go to definition")
                    map("gD", vim.lsp.buf.declaration, "Go to declaration")
                    map("gr", vim.lsp.buf.references, "References")
                    map("K", vim.lsp.buf.hover, "Documentation")

                    map(
                        "<leader>rn",
                        vim.lsp.buf.rename,
                        "Rename symbol"
                    )

                    map(
                        "<leader>ca",
                        vim.lsp.buf.code_action,
                        "Code action"
                    )

                    map(
                        "<leader>cf",
                        function()
                            vim.lsp.buf.format({
                                async = true,
                            })
                        end,
                        "Format buffer"
                    )
                end,
            })
        end,
    },
}

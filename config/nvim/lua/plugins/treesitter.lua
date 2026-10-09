return {
    {
        "nvim-treesitter/nvim-treesitter",
        lazy = false,
        build = ":TSUpdate",

        config = function()
            local treesitter = require("nvim-treesitter")

            local languages = {
                "bash",
                "c",
                "cpp",
                "css",
                "fish",
                "html",
                "javascript",
                "json",
                "latex",
                "lua",
                "markdown",
                "markdown_inline",
                "python",
                "toml",
                "typescript",
                "vim",
                "vimdoc",
                "yaml",
            }

            treesitter.install(languages)

            vim.api.nvim_create_autocmd("FileType", {
                pattern = {
                    "bash",
                    "c",
                    "cpp",
                    "css",
                    "fish",
                    "html",
                    "javascript",
                    "json",
                    "lua",
                    "markdown",
                    "markdown_inline",
                    "python",
                    "tex",
                    "toml",
                    "typescript",
                    "vim",
                    "vimdoc",
                    "yaml",
                },

                callback = function(args)
                    local lang = vim.treesitter.language.get_lang(
                        vim.bo[args.buf].filetype
                    )

                    if not lang then
                        return
                    end

                    pcall(vim.treesitter.start, args.buf, lang)

                    vim.bo[args.buf].indentexpr =
                        "v:lua.require'nvim-treesitter'.indentexpr()"
                end,
            })
        end,
    },
}

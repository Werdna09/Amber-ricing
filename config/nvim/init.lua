vim.g.mapleader = " "
vim.g.maplocalleader = " "

require("crylia.options")
require("crylia.keymaps")
require("crylia.autocmds")

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not vim.uv.fs_stat(lazypath) then
    local result = vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable",
        lazypath,
    })

    if vim.v.shell_error ~= 0 then
        error("Could not install lazy.nvim:\n" .. result)
    end
end

vim.opt.rtp:prepend(lazypath)

require("lazy").setup("plugins", {
    install = {
        colorscheme = { "sonokai" },
    },

    checker = {
        enabled = false,
    },

    change_detection = {
        notify = false,
    },

    ui = {
        border = "rounded",
    },
})

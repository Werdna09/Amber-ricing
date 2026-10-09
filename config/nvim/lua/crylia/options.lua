local opt = vim.opt

opt.number = true
opt.relativenumber = true
opt.cursorline = true
opt.signcolumn = "yes"
opt.termguicolors = true
opt.showmode = false
opt.showcmd = false
opt.laststatus = 3
opt.winborder = "rounded"

opt.mouse = "a"
opt.clipboard = "unnamedplus"
opt.undofile = true
opt.swapfile = false
opt.backup = false
opt.writebackup = false
opt.confirm = true

opt.tabstop = 4
opt.shiftwidth = 4
opt.softtabstop = 4
opt.expandtab = true
opt.smartindent = true

opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true
opt.incsearch = true

opt.splitright = true
opt.splitbelow = true
opt.scrolloff = 6
opt.sidescrolloff = 6

opt.updatetime = 250
opt.timeoutlen = 400

opt.wrap = false
opt.breakindent = true

opt.completeopt = { "menu", "menuone", "noselect" }
opt.virtualedit = "block"

opt.title = true
opt.titlestring = "nvim — %t"

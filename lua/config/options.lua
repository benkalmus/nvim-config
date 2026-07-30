-- Options are automatically loaded before lazy.nvim startup.

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"
vim.g.lazyvim_picker = "snacks"
vim.g.lazyvim_cmp = "blink.cmp"

local opt = vim.opt

opt.modeline = false
opt.relativenumber = true
opt.wrap = false
-- Timeout (ms) waiting for mapped key-sequence to complete (e.g. escape sequences in terminal). This fixes esc being interpreted as alt key. An annoyance when moving lines.
opt.ttimeoutlen = 10

-- Show search count, e.g. "[1/5]".
opt.shortmess:remove("S")

opt.tabstop = 4
opt.shiftwidth = 4
opt.softtabstop = 4
opt.expandtab = true

-- Tree-sitter fold expressions run repeatedly while drawing. Keep folds manual
-- until explicitly created with `zf`.
opt.foldmethod = "manual"
opt.foldexpr = "0"
opt.foldlevel = 99
opt.foldlevelstart = 99
opt.foldenable = true
opt.autoread = true
opt.jumpoptions:append("clean")
opt.sessionoptions = "buffers,curdir,tabpages,winsize,help,globals,skiprtp,folds"

opt.listchars = { tab = "· " }

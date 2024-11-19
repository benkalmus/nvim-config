-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
--

local opt = vim.opt
opt.shiftwidth = 4 -- Size of an indent
opt.tabstop = 4 -- Number of spaces tabs count for
opt.timeoutlen = 150 -- vim.g.vscode and 1000 or 300 --  Lower than default (1000) to quickly trigger which-key

-- disable auto format on save
-- vim.g.autoformat = false

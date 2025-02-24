-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local map = vim.keymap

-- remove default mapping which opens Help. can still access with :help
map.set({ "v", "n", "i", "c" }, "<F1>", "<Nop>")

-- rebind deletions to black hole register _
map.set({ "n", "v" }, "x", '"_x', { noremap = true })
map.set({ "n", "v" }, "X", '"_dd', { noremap = true })
map.set({ "n", "v" }, "D", '"_D', { noremap = true })
-- map.set({ "n", "v" }, "dd", '"_dd', { noremap = true })
map.set({ "n", "v" }, "C", '"_C', { noremap = true })
map.set({ "n", "v" }, "c", '"_c', { noremap = true })

-- Changes P behaviour to pasting from the 0 register rather than the last thing yanked
-- map.set({ "n", "v" }, "P", '"0p', { noremap = true })
map.set({ "n", "v" }, "<C-p>", '"0P', { noremap = true })
-- copy to system clipboard
map.set({ "n", "v" }, "Y", '"+y', { noremap = true })

-- jumps back to first char on line, also equivalent to hitting ^
map.set({ "n", "v" }, "-", "_", { noremap = true })

-- comfy horizontal scrolling
map.set({ "n", "v" }, "zl", "zL", { noremap = true })
map.set({ "n", "v" }, "zh", "zH", { noremap = true })

-- Add custom command to reload key mapping file
vim.api.nvim_create_user_command("ReloadKeymaps", "luafile ~/.config/nvim/lua/config/keymaps.lua", {})
vim.api.nvim_create_user_command("ReloadOptions", "luafile ~/.config/nvim/lua/config/options.lua", {})

-- files
vim.api.nvim_set_keymap("n", "QQ", ":qa<enter>", { noremap = false })
vim.api.nvim_set_keymap("n", "WW", ":wa<enter>", { noremap = false })

-- TODO: no longer needed ( using fzf )
-- Define a Lua function for live_grep with a glob pattern
function TelescopeLiveGrepGlob(glob_pattern)
    -- Call the Telescope live_grep with the glob_pattern
    require("telescope.builtin").live_grep({
        glob_pattern = glob_pattern,
    })
end
-- Create a keybinding for this function
map.set(
    { "n", "v" }, -- Normal mode
    "<leader>sf", -- Keybinding (change as you like)
    [[:lua TelescopeLiveGrepGlob(vim.fn.input("Glob pattern: "))<CR>]], -- Function call with user input
    { noremap = true, silent = true }
)

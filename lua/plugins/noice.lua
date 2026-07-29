return {
	"folke/noice.nvim",
	opts = {
		lsp = {
			override = {
				["cmp.entry.get_documentation"] = {
					enabled = false,
				},
				["vim.lsp.util.stylize_markdown"] = {
					enabled = false,
				},
				["vim.lsp.util.convert_input_to_markdown_lines"] = {
					enabled = false,
				},
			},
			signature = {
				enabled = false,
			},
			hover = {
				enabled = false,
			},
		},
		notify = {
			enabled = false,
		},
	},
}
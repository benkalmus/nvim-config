return {
	"Bekaboo/dropbar.nvim",
	event = "LazyFile",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	keys = {
		{
			"<leader>;",
			function()
				require("dropbar.api").pick()
			end,
			desc = "Pick Symbols in Winbar",
		},
	},
	opts = {
		bar = {
			hover = false,
			update_debounce = 100,
		},
	},
}

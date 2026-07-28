return {
	{
		"stevearc/conform.nvim",
		opts = require("config.conform"),
	},

	{
		"mason-org/mason.nvim",
		opts = { ensure_installed = { "biome" } },
	},
}

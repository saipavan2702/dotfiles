local tools = {
	"prettier",
	"stylua",
	"isort",
	"black",
	"eslint_d",
	"shellcheck",
	"shfmt",
	"clang-format",
	"markdownlint-cli2",
	"yamllint",
	"sqlfluff",
}

return {
	{
		"williamboman/mason.nvim",
		lazy = false,
		config = function()
			require("mason").setup({
				ui = {
					icons = {
						package_installed = "✓",
						package_pending = "➜",
						package_uninstalled = "✗",
					},
				},
			})
		end,
	},

	{
		"williamboman/mason-lspconfig.nvim",
		cmd = { "LspInstall", "LspUninstall" },
		dependencies = { "williamboman/mason.nvim" },
	},

	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		cmd = {
			"MasonToolsClean",
			"MasonToolsInstall",
			"MasonToolsInstallSync",
			"MasonToolsUpdate",
			"MasonToolsUpdateSync",
		},
		dependencies = { "williamboman/mason.nvim" },
		opts = {
			ensure_installed = tools,
			run_on_start = false,
			integrations = {
				["mason-lspconfig"] = false,
				["mason-null-ls"] = false,
				["mason-nvim-dap"] = false,
			},
		},
		config = function(_, opts)
			require("mason-tool-installer").setup(opts)
		end,
	},
}

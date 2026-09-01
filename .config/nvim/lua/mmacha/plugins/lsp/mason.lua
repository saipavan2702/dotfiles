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
		"mason-org/mason.nvim",
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
		"mason-org/mason-lspconfig.nvim",
		event = { "BufReadPre", "BufNewFile" },
		cmd = { "LspInstall", "LspUninstall" },
		dependencies = { "mason-org/mason.nvim", "neovim/nvim-lspconfig" },
		opts = {
			ensure_installed = require("mmacha.lsp.servers"),
			automatic_enable = false,
		},
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
		dependencies = { "mason-org/mason.nvim" },
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

local enabled_servers = {
	"lua_ls",
	"html",
	"cssls",
	"jsonls",
	"yamlls",
	"marksman",
	"bashls",
	"emmet_ls",
	"pyright",
	"ruff",
	"ts_ls",
	"rust_analyzer",
	"clangd",
	"jdtls",
	"sqlls",
	"gopls",
	"astro",
	"tailwindcss",
}

local server_configs = {
	lua_ls = {
		settings = {
			Lua = {
				diagnostics = { globals = { "vim" } },
				completion = { callSnippet = "Replace" },
				workspace = {
					library = {
						[vim.fn.expand("$VIMRUNTIME/lua")] = true,
						[vim.fn.stdpath("config") .. "/lua"] = true,
					},
				},
			},
		},
	},

	emmet_ls = {
		filetypes = {
			"html",
			"typescriptreact",
			"javascriptreact",
			"css",
			"sass",
			"scss",
			"less",
			"svelte",
		},
	},

	gopls = {
		settings = {
			gopls = {
				analyses = { unusedparams = true },
				staticcheck = true,
				gofumpt = true,
			},
		},
	},

	pyright = {
		settings = {
			python = {
				analysis = {
					autoSearchPaths = true,
					diagnosticMode = "workspace",
					typeCheckingMode = "basic",
					useLibraryCodeForTypes = true,
				},
			},
		},
	},

	rust_analyzer = {
		settings = {
			["rust-analyzer"] = {
				cargo = { allFeatures = true },
				check = { command = "clippy" },
			},
		},
	},

	clangd = {
		cmd = {
			"clangd",
			"--background-index",
			"--completion-style=detailed",
			"--header-insertion=iwyu",
			"--fallback-style=llvm",
			"--query-driver=/opt/homebrew/bin/g++-*,/usr/local/bin/g++-*",
		},
		init_options = {
			fallbackFlags = {
				"-std=c++20",
				"-I/Users/mmacha/dotfiles/.config/nvim/clangd/include",
			},
		},
	},

	tailwindcss = {
		filetypes = {
			"html",
			"css",
			"javascript",
			"typescript",
			"javascriptreact",
			"typescriptreact",
			"svelte",
			"vue",
			"astro",
		},
		init_options = {
			userLanguages = { astro = "html" },
		},
	},

	ts_ls = {
		single_file_support = true,
		init_options = {
			preferences = {
				includeCompletionsForImportStatements = true,
				includeCompletionsForModuleExports = true,
			},
		},
	},

	yamlls = {
		settings = {
			yaml = { keyOrdering = false },
		},
	},
}

return {
	"neovim/nvim-lspconfig",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		"hrsh7th/cmp-nvim-lsp",
		{ "antosha417/nvim-lsp-file-operations", config = true },
	},
	config = function()
		local function telescope(name, opts)
			return function()
				require("telescope.builtin")[name](opts or {})
			end
		end

		vim.api.nvim_create_autocmd("LspAttach", {
			group = vim.api.nvim_create_augroup("UserLspConfig", { clear = true }),
			callback = function(ev)
				local function map(mode, lhs, rhs, desc)
					vim.keymap.set(mode, lhs, rhs, { buffer = ev.buf, silent = true, desc = desc })
				end

				map("n", "gR", telescope("lsp_references"), "Show LSP references")
				map("n", "gD", vim.lsp.buf.declaration, "Go to declaration")
				map("n", "gd", telescope("lsp_definitions"), "Show LSP definitions")
				map("n", "gi", telescope("lsp_implementations"), "Show LSP implementations")
				map("n", "gt", telescope("lsp_type_definitions"), "Show LSP type definitions")
				map({ "n", "v" }, "<leader>vca", vim.lsp.buf.code_action, "Code actions")
				map("n", "<leader>rn", vim.lsp.buf.rename, "Smart rename")
				map("n", "<leader>D", telescope("diagnostics", { bufnr = ev.buf }), "Show buffer diagnostics")
				map("n", "<leader>ld", vim.diagnostic.open_float, "Show line diagnostics")
				map("n", "K", vim.lsp.buf.hover, "Show documentation")
				map("n", "<leader>rs", "<cmd>LspRestart<CR>", "Restart LSP")
				map("n", "[d", vim.diagnostic.goto_prev, "Go to previous diagnostic")
				map("n", "]d", vim.diagnostic.goto_next, "Go to next diagnostic")
				map("i", "<C-h>", vim.lsp.buf.signature_help, "Signature help")
			end,
		})

		vim.diagnostic.config({
			signs = {
				text = {
					[vim.diagnostic.severity.ERROR] = " ",
					[vim.diagnostic.severity.WARN] = " ",
					[vim.diagnostic.severity.HINT] = "󰠠 ",
					[vim.diagnostic.severity.INFO] = " ",
				},
			},
			underline = true,
			update_in_insert = false,
			virtual_text = {
				spacing = 4,
				source = "if_many",
			},
		})

		vim.lsp.config("*", {
			capabilities = require("cmp_nvim_lsp").default_capabilities(),
		})

		for _, server in ipairs(enabled_servers) do
			vim.lsp.config(server, server_configs[server] or {})
			vim.lsp.enable(server)
		end
	end,
}

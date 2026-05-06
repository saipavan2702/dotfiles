local formatters_by_ft = {
	bash = { "shfmt" },
	c = { "clang_format" },
	cpp = { "clang_format" },
	css = { "prettier" },
	graphql = { "prettier" },
	html = { "prettier" },
	javascript = { "prettier" },
	javascriptreact = { "prettier" },
	json = { "prettier" },
	jsonc = { "prettier" },
	lua = { "stylua" },
	markdown = { "prettier", "markdown-toc" },
	python = { "isort", "black" },
	rust = { "rustfmt" },
	sh = { "shfmt" },
	sql = { "sqlfluff" },
	svelte = { "prettier" },
	typescript = { "prettier" },
	typescriptreact = { "prettier" },
	yaml = { "prettier" },
}

return {
	"stevearc/conform.nvim",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		local conform = require("conform")

		conform.setup({
			formatters = {
				["markdown-toc"] = {
					condition = function(_, ctx)
						for _, line in ipairs(vim.api.nvim_buf_get_lines(ctx.buf, 0, -1, false)) do
							if line:find("<!%-%- toc %-%->") then
								return true
							end
						end
					end,
				},
				prettier = {
					args = {
						"--stdin-filepath",
						"$FILENAME",
						"--tab-width",
						"4",
						"--use-tabs",
						"false",
					},
				},
				shfmt = {
					prepend_args = { "-i", "4" },
				},
			},
			formatters_by_ft = formatters_by_ft,
		})

		vim.keymap.set({ "n", "v" }, "<leader>mp", function()
			conform.format({
				async = false,
				lsp_fallback = true,
				timeout_ms = 1000,
			})
		end, { desc = "Format whole file or range" })
	end,
}

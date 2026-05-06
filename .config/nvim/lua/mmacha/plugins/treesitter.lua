local parsers = {
	"bash",
	"c",
	"cpp",
	"css",
	"dockerfile",
	"gitignore",
	"go",
	"gomod",
	"gosum",
	"graphql",
	"html",
	"http",
	"java",
	"javascript",
	"json",
	"lua",
	"luadoc",
	"markdown",
	"markdown_inline",
	"prisma",
	"python",
	"query",
	"ron",
	"rust",
	"sql",
	"svelte",
	"tsx",
	"typescript",
	"vim",
	"vimdoc",
	"yaml",
}

local function start_treesitter(args)
	local filetype = vim.bo[args.buf].filetype
	local language = vim.treesitter.language.get_lang(filetype)

	if not language then
		return
	end

	local ok = pcall(vim.treesitter.start, args.buf, language)
	if not ok then
		return
	end

	local has_indents, indent_query = pcall(vim.treesitter.query.get, language, "indents")
	if has_indents and indent_query then
		vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
	end
end

return {
	{
		"nvim-treesitter/nvim-treesitter",
		lazy = false,
		build = ":TSUpdate",
		config = function()
			local treesitter = require("nvim-treesitter")

			treesitter.setup()
			vim.treesitter.language.register("bash", "zsh")

			vim.api.nvim_create_user_command("TSInstallConfigured", function()
				treesitter.install(parsers, { summary = true })
			end, { desc = "Install configured Treesitter parsers" })

			vim.api.nvim_create_autocmd("FileType", {
				group = vim.api.nvim_create_augroup("UserTreesitter", { clear = true }),
				pattern = "*",
				callback = start_treesitter,
			})
		end,
	},
	{
		"windwp/nvim-ts-autotag",
		ft = { "html", "xml", "javascript", "typescript", "javascriptreact", "typescriptreact", "svelte" },
		opts = {
			opts = {
				enable_close = true,
				enable_rename = true,
				enable_close_on_slash = false,
			},
			per_filetype = {
				html = { enable_close = true },
				typescriptreact = { enable_close = true },
			},
		},
	},
}

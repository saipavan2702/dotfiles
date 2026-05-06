local linters_by_ft = {
	bash = { "shellcheck" },
	javascript = { "eslint_d" },
	javascriptreact = { "eslint_d" },
	markdown = { "markdownlint-cli2" },
	sh = { "shellcheck" },
	sql = { "sqlfluff" },
	svelte = { "eslint_d" },
	typescript = { "eslint_d" },
	typescriptreact = { "eslint_d" },
	yaml = { "yamllint" },
}

return {
	"mfussenegger/nvim-lint",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		local lint = require("lint")
		lint.linters_by_ft = linters_by_ft

		local eslint = lint.linters.eslint_d
		if eslint then
			eslint.args = {
				"--no-warn-ignored",
				"--format",
				"json",
				"--stdin",
				"--stdin-filename",
				function()
					return vim.fn.expand("%:p")
				end,
			}
		end

		local function has_config(names)
			return #vim.fs.find(names, {
				upward = true,
				path = vim.api.nvim_buf_get_name(0),
				type = "file",
			}) > 0
		end

		local function linter_is_ready(name)
			if name == "eslint_d" then
				return has_config({
					"eslint.config.js",
					"eslint.config.mjs",
					"eslint.config.cjs",
					".eslintrc",
					".eslintrc.js",
					".eslintrc.cjs",
					".eslintrc.json",
					"package.json",
				})
			end

			if name == "sqlfluff" then
				return has_config({ ".sqlfluff", "pyproject.toml", "setup.cfg", "tox.ini" })
			end

			local linter = lint.linters[name]
			local cmd = type(linter) == "table" and linter.cmd or name
			return type(cmd) ~= "string" or vim.fn.executable(cmd) == 1
		end

		local function linters_for_buffer()
			local names = lint.linters_by_ft[vim.bo.filetype]
			if not names then
				return nil
			end

			local available = {}
			for _, name in ipairs(names) do
				if linter_is_ready(name) then
					table.insert(available, name)
				end
			end

			return available
		end

		local function try_lint()
			local ok, err = pcall(lint.try_lint, linters_for_buffer())
			if not ok then
				vim.notify("lint failed: " .. err, vim.log.levels.WARN)
			end
		end

		local lint_group = vim.api.nvim_create_augroup("UserLint", { clear = true })
		vim.api.nvim_create_autocmd("BufWritePost", {
			group = lint_group,
			callback = try_lint,
		})

		vim.keymap.set("n", "<leader>l", function()
			try_lint()
		end, { desc = "Trigger linting for current file" })
	end,
}

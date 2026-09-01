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

		local function find_config(names)
			local path = vim.api.nvim_buf_get_name(0)
			local start_path = path ~= "" and vim.fs.dirname(path) or vim.uv.cwd()

			return vim.fs.find(names, {
				upward = true,
				path = start_path,
				type = "file",
			})[1]
		end

		local function has_package_eslint_config()
			local package_json = find_config({ "package.json" })
			if not package_json then
				return false
			end

			local ok, contents = pcall(vim.fn.readfile, package_json)
			if not ok then
				return false
			end

			local decoded_ok, package = pcall(vim.json.decode, table.concat(contents, "\n"))
			return decoded_ok and type(package) == "table" and package.eslintConfig ~= nil
		end

		local function linter_is_ready(name)
			local linter = lint.linters[name]
			local cmd = type(linter) == "table" and linter.cmd or name
			if type(cmd) == "function" then
				local ok, resolved_cmd = pcall(cmd)
				if not ok then
					return false
				end
				cmd = resolved_cmd
			end

			if type(cmd) == "string" and vim.fn.executable(cmd) == 0 then
				return false
			end

			if name == "eslint_d" then
				return find_config({
					"eslint.config.js",
					"eslint.config.mjs",
					"eslint.config.cjs",
					".eslintrc",
					".eslintrc.js",
					".eslintrc.cjs",
					".eslintrc.json",
					".eslintrc.yml",
					".eslintrc.yaml",
				}) ~= nil or has_package_eslint_config()
			end

			if name == "sqlfluff" then
				return find_config({ ".sqlfluff", "pyproject.toml", "setup.cfg", "tox.ini" }) ~= nil
			end

			return true
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

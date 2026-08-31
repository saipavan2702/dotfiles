local cf_path = vim.fs.joinpath(vim.fn.expand("~"), "cp-sublime")
local include_path = vim.fs.joinpath(vim.fn.stdpath("config"), "clangd", "include")
local extractor_path = vim.fs.joinpath(vim.fn.expand("~"), ".cargo", "bin", "codeforces-extractor")
local sublime_cpp_snippet = vim.fs.joinpath(
	vim.fn.expand("~"),
	"Library",
	"Application Support",
	"Sublime Text",
	"Packages",
	"User",
	"batman.sublime-snippet"
)

local function ensure_cpp_template()
	local template_dir = vim.fs.joinpath(cf_path, "contests", "templates")
	local template_file = vim.fs.joinpath(template_dir, "template.cpp")

	if vim.fn.filereadable(template_file) == 1 then
		return
	end

	vim.fn.mkdir(template_dir, "p")

	if vim.fn.filereadable(sublime_cpp_snippet) == 1 then
		local snippet = table.concat(vim.fn.readfile(sublime_cpp_snippet), "\n")
		local template = snippet:match("<!%[CDATA%[(.*)%]%]>")

		if template and template ~= "" then
			template = template:gsub("^%s*\n", ""):gsub("%s*$", "\n")
			vim.fn.writefile(vim.split(template, "\n", { plain = true }), template_file)
			return
		end
	end

	vim.fn.writefile({
		"#include <bits/stdc++.h>",
		"using namespace std;",
		"",
		"int main() {",
		"    ios::sync_with_stdio(false);",
		"    cin.tie(nullptr);",
		"",
		"    return 0;",
		"}",
	}, template_file)
end

local function patch_fetch_problems()
	local codeforces = require("codeforces-nvim.codeforces")
	local utils = require("codeforces-nvim.utils")

	if codeforces._mmacha_fetch_patch then
		return
	end

	codeforces.fetch_problems = function(contest, save_dir, use_native_display, exit_function)
		if type(use_native_display) == "function" and exit_function == nil then
			exit_function = use_native_display
			use_native_display = codeforces.options.use_native_display
		elseif use_native_display == nil then
			use_native_display = codeforces.options.use_native_display
		end

		local command = {
			codeforces.options.extractor_path,
			contest,
			"--save-path",
			save_dir,
		}

		if use_native_display then
			table.insert(command, "--native-display")
		end

		vim.fn.jobstart(command, {
			on_stderr = function(_, data)
				if utils.check_data(data) == false then
					return
				end
				codeforces.options.notify("Codeforces Extractor", vim.inspect(data), "error")
			end,
			on_exit = function(_, code)
				if code ~= 0 then
					codeforces.options.notify("Codeforces Extractor", "Problem fetch failed.", "error")
					return
				end

				if type(exit_function) == "function" then
					exit_function()
				end
			end,
		})
	end

	codeforces._mmacha_fetch_patch = true
end

return {
	{
		"akinsho/toggleterm.nvim",
		version = "*",
		cmd = {
			"ToggleTerm",
			"TermExec",
			"TermNew",
			"TermSelect",
		},
		opts = {
			direction = "horizontal",
			size = 12,
			close_on_exit = false,
			shade_terminals = false,
		},
	},
	{
		"yunusey/codeforces-nvim",
		cmd = {
			"EnterContest",
			"QNext",
			"TestCurrent",
			"RunCurrent",
			"CreateTestCase",
			"RetrieveLastTestCase",
		},
		keys = {
			{ "<leader>ce", "<cmd>EnterContest<CR>", desc = "Enter Codeforces contest" },
			{ "<leader>cn", "<cmd>QNext<CR>", desc = "Next Codeforces problem" },
			{ "<leader>ct", "<cmd>TestCurrent<CR>", desc = "Test Codeforces problem" },
			{ "<leader>cr", "<cmd>RunCurrent<CR>", desc = "Run Codeforces problem" },
			{ "<leader>ci", "<cmd>CreateTestCase<CR>", desc = "Create Codeforces test" },
			{ "<leader>cl", "<cmd>RetrieveLastTestCase<CR>", desc = "Run last Codeforces test" },
		},
		dependencies = {
			"nvim-lua/plenary.nvim",
			"akinsho/toggleterm.nvim",
		},
		config = function()
			local codeforces = require("codeforces-nvim")

				codeforces.setup({
					cf_path = cf_path,
					extractor_path = extractor_path,
					use_native_display = true,
				extension = "cpp",
				lines = {
					cpp = 7,
					py = 1,
				},
				timeout = 10000,
				compiler = {
					cpp = { "cp-g++", "-std=c++20", "-O2", "-Wall", "-Wextra", "-I" .. include_path, "@.cpp", "-o", "@" },
					py = {},
				},
				run = {
					cpp = { "@" },
					py = { "python3", "@.py" },
				},
				use_term_toggle = true,
				notify = function(title, message, type)
					local level = type == "error" and vim.log.levels.ERROR or vim.log.levels.INFO
					vim.notify(message or title, level, { title = message and title or nil })
				end,
			})

			patch_fetch_problems()
			ensure_cpp_template()
		end,
	},
}

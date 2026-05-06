local excluded = { ".git", "node_modules", "dist", "build" }

local function current_dir()
	local name = vim.api.nvim_buf_get_name(0)
	return name ~= "" and vim.fs.dirname(name) or vim.uv.cwd()
end

local function clean_opts(opts)
	if type(opts) ~= "table" or opts.items or opts.sections then
		return {}
	end

	return opts
end

local function picker()
	return require("snacks").picker
end

local function picker_opts(opts)
	return vim.tbl_deep_extend("force", {
		layout = { preset = "telescope" },
	}, clean_opts(opts))
end

local function file_opts(opts)
	return vim.tbl_deep_extend("force", {
		hidden = true,
		ignored = false,
		exclude = excluded,
		layout = { preset = "telescope" },
	}, clean_opts(opts))
end

local function find_files(opts)
	picker().files(file_opts(opts))
end

local function live_grep(opts)
	picker().grep(file_opts(opts))
end

local function recent_files(opts)
	picker().recent(picker_opts(opts))
end

local function dashboard_status()
	local ok, lazy_stats = pcall(require, "lazy.stats")
	local time = os.date("%I:%M %p")

	if not ok then
		return {
			align = "center",
			text = {
				{ " " .. time, hl = "footer" },
			},
		}
	end

	local stats = lazy_stats.stats()
	local ms = math.floor(stats.startuptime * 100 + 0.5) / 100

	return {
		align = "center",
		text = {
			{ " " .. time, hl = "footer" },
			{ "  •  ", hl = "footer" },
			{ "Neovim loaded ", hl = "footer" },
			{ stats.loaded .. "/" .. stats.count, hl = "special" },
			{ " plugins in ", hl = "footer" },
			{ ms .. "ms", hl = "special" },
		},
	}
end

local function patch_snacks_picker_finder()
	local Finder = require("snacks.picker.core.finder")
	if Finder._mmacha_safe_run then
		return
	end

	local Async = require("snacks.picker.util.async")
	local yield_find_ms = 1

	function Finder:run(active_picker)
		local default_score = require("snacks.picker.core.matcher").DEFAULT_SCORE
		self.task:abort()
		self.items = {}

		local ctx = self:ctx(active_picker)
		local finder = self._find(active_picker.opts, ctx)
		local limit = (active_picker.opts.live and active_picker.opts.limit_live or active_picker.opts.limit)
			or math.huge
		local yield

		local function picker_alive(task)
			return task == self.task
				and not active_picker.closed
				and active_picker.matcher
				and active_picker.matcher.task
		end

		local function add(item)
			item.idx, item.score = #self.items + 1, default_score
			self.items[item.idx] = item
		end

		if active_picker.opts.transform then
			local transform = Snacks.picker.config.transform(active_picker.opts)
			function add(item)
				local transformed = transform(item, ctx)
				item = type(transformed) == "table" and transformed or item
				if transformed ~= false then
					item.idx, item.score = #self.items + 1, default_score
					self.items[item.idx] = item
				end
			end
		end

		if type(finder) == "table" then
			for _, item in ipairs(finder) do
				add(item)
			end
			return
		end

		local running = true
		local task

		collectgarbage("stop")
		task = Async.new(function()
			ctx.async = Async.running()
			finder(function(item)
				if not running or not picker_alive(task) then
					return
				end
				if #self.items >= limit then
					return task:abort()
				end
				add(item)
				active_picker.matcher.task:resume()
				yield = yield or Async.yielder(yield_find_ms)
				yield()
			end)
		end)

		self.task = task
		task:on("done", function()
			collectgarbage("restart")
			if not task:aborted() and picker_alive(task) then
				active_picker.matcher.task:resume()
				active_picker:update()
			end
			running = false
		end)
	end

	Finder._mmacha_safe_run = true
end

return {
	-- HACK: docs @ https://github.com/folke/snacks.nvim/blob/main/docs
	{
		"folke/snacks.nvim",
		priority = 1000,
		lazy = false,
		-- NOTE: Options
		opts = {
			styles = {
				input = {
					keys = {
						n_esc = { "<C-c>", { "cmp_close", "cancel" }, mode = "n", expr = true },
						i_esc = { "<C-c>", { "cmp_close", "stopinsert" }, mode = "i", expr = true },
					},
				},
			},
			-- Snacks Modules
			input = {
				enabled = true,
			},
			quickfile = {
				enabled = true,
				exclude = { "latex" },
			},
			-- HACK: read picker docs @ https://github.com/folke/snacks.nvim/blob/main/docs/picker.md
			picker = {
				enabled = true,
				matcher = {
					frecency = true,
					cwd_bonus = false,
					sort_empty = true,
				},
				formatters = {
					file = {
						filename_first = true,
						filename_only = false,
						icon_width = 2,
					},
				},
				sources = {
					files = {
						hidden = true,
						ignored = false,
						exclude = excluded,
					},
					grep = {
						hidden = true,
						ignored = false,
						exclude = excluded,
					},
					explorer = {
						hidden = true,
						ignored = false,
						exclude = excluded,
					},
				},
				layout = {
					preset = "telescope",
					cycle = false,
				},
			},
			-- image = {
			--     enabled = function()
			--         return vim.bo.filetype == "markdown"
			--     end,
			--     doc = {
			--         float = false, -- show image on cursor hover
			--         inline = false, -- show image inline
			--         max_width = 50,
			--         max_height = 30,
			--         wo = {
			--             wrap = false,
			--         },
			--     },
			--     convert = {
			--         notify = true,
			--         command = "magick"
			--     },
			--     img_dirs = { "img", "images", "assets", "static", "public", "media", "attachments","Archives/All-Vault-Images/", "~/Library", "~/Downloads" },
			-- },
			dashboard = {
				enabled = true,
				sections = {
					{ section = "header" },
					{ section = "keys", gap = 1, padding = 1 },
					dashboard_status,
				},
				preset = {
					pick = function(cmd, opts)
						if cmd == "files" then
							find_files(opts)
						elseif cmd == "live_grep" then
							live_grep(opts)
						elseif cmd == "oldfiles" then
							recent_files(opts)
						else
							picker()[cmd](picker_opts(opts))
						end
					end,
					keys = {
						{
							icon = " ",
							key = "f",
							desc = "Find File",
							action = function()
								find_files()
							end,
						},
						{
							icon = " ",
							key = "F",
							desc = "Find Here",
							action = function()
								find_files({ cwd = current_dir() })
							end,
						},
						{
							icon = " ",
							key = "g",
							desc = "Find Text",
							action = function()
								live_grep()
							end,
						},
						{
							icon = " ",
							key = "r",
							desc = "Recent Files",
							action = function()
								recent_files()
							end,
						},
						{
							icon = " ",
							key = "c",
							desc = "Config",
							action = function()
								find_files({ cwd = vim.fn.stdpath("config") })
							end,
						},
						{ icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
						{ icon = "󰒲 ", key = "L", desc = "Lazy", action = ":Lazy" },
						{ icon = " ", key = "q", desc = "Quit", action = ":qa" },
					},
					header = [[
 ██╗  ██╗██╗██╗     ██╗     ███████╗██████╗ ███╗   ███╗ █████╗  ██████╗██╗  ██╗ █████╗
 ██║ ██╔╝██║██║     ██║     ██╔════╝██╔══██╗████╗ ████║██╔══██╗██╔════╝██║  ██║██╔══██╗
 █████╔╝ ██║██║     ██║     █████╗  ██████╔╝██╔████╔██║███████║██║     ███████║███████║
 ██╔═██╗ ██║██║     ██║     ██╔══╝  ██╔══██╗██║╚██╔╝██║██╔══██║██║     ██╔══██║██╔══██║
 ██║  ██╗██║███████╗███████╗███████╗██║  ██║██║ ╚═╝ ██║██║  ██║╚██████╗██║  ██║██║  ██║
 ╚═╝  ╚═╝╚═╝╚══════╝╚══════╝╚══════╝╚═╝  ╚═╝╚═╝     ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝╚═╝  ╚═╝]],
				},
			},
		},
		config = function(_, opts)
			patch_snacks_picker_finder()
			require("snacks").setup(opts)

			vim.api.nvim_create_user_command("FindFiles", function()
				find_files()
			end, { desc = "Find files" })

			vim.api.nvim_create_user_command("FindFilesHere", function()
				find_files({ cwd = current_dir() })
			end, { desc = "Find files in current file directory" })

			vim.api.nvim_create_user_command("FindConfigFiles", function()
				find_files({ cwd = vim.fn.stdpath("config") })
			end, { desc = "Find Neovim config files" })

			vim.api.nvim_create_user_command("FindText", function()
				live_grep()
			end, { desc = "Live grep" })
		end,
		-- NOTE: Keymaps
		keys = {
			{
				"<leader>ff",
				find_files,
				desc = "Find Files",
			},
			{
				"<leader>fF",
				function()
					find_files({ cwd = current_dir() })
				end,
				desc = "Find Files in Current Dir",
			},
			{
				"<leader>fg",
				live_grep,
				desc = "Find Text",
			},
			{
				"<leader>fr",
				recent_files,
				desc = "Find Recent Files",
			},
			{
				"<leader>lg",
				function()
					require("snacks").lazygit()
				end,
				desc = "Lazygit",
			},
			{
				"<leader>gl",
				function()
					require("snacks").lazygit.log()
				end,
				desc = "Lazygit Logs",
			},
			{
				"<leader>rN",
				function()
					require("snacks").rename.rename_file()
				end,
				desc = "Fast Rename Current File",
			},
			{
				"<leader>dB",
				function()
					require("snacks").bufdelete()
				end,
				desc = "Delete or Close Buffer  (Confirm)",
			},
			{
				"<leader>oo",
				find_files,
				desc = "Open File Picker",
			},
			{
				"<leader>of",
				find_files,
				desc = "Find Files",
			},
			{
				"<leader>oF",
				function()
					find_files({ cwd = current_dir() })
				end,
				desc = "Find Files in Current Dir",
			},
			{
				"<leader>oc",
				function()
					find_files({ cwd = vim.fn.stdpath("config") })
				end,
				desc = "Find Config File",
			},
			{
				"<leader>pf",
				find_files,
				desc = "Find Files",
			},
			{
				"<leader>pF",
				function()
					find_files({ cwd = current_dir() })
				end,
				desc = "Find Files in Current Dir",
			},
			{
				"<leader>pc",
				function()
					find_files({ cwd = vim.fn.stdpath("config") })
				end,
				desc = "Find Config File",
			},
			{
				"<leader>pb",
				function()
					picker().buffers(picker_opts())
				end,
				desc = "Find Buffers",
			},
			{
				"<leader>pr",
				recent_files,
				desc = "Find Recent Files",
			},
			{
				"<leader>pg",
				function()
					picker().git_files(picker_opts())
				end,
				desc = "Find Git Files",
			},
			{
				"<leader>pR",
				function()
					picker().resume()
				end,
				desc = "Resume Picker",
			},
			{
				"<leader>pd",
				function()
					picker().diagnostics(picker_opts())
				end,
				desc = "Find Diagnostics",
			},
			{
				"<leader>pl",
				function()
					picker().lines(picker_opts())
				end,
				desc = "Find Lines in Buffer",
			},
			{
				"<leader>pC",
				function()
					picker().commands(picker_opts({ layout = { preset = "select" } }))
				end,
				desc = "Find Commands",
			},
			{
				"<leader>ps",
				live_grep,
				desc = "Grep",
			},
			{
				"<leader>pws",
				function()
					picker().grep_word(file_opts())
				end,
				desc = "Search Selection or Word",
				mode = { "n", "x" },
			},
			{
				"<leader>pk",
				function()
					picker().keymaps(picker_opts({ layout = { preset = "ivy" } }))
				end,
				desc = "Search Keymaps",
			},
			{
				"<leader>gbr",
				function()
					picker().git_branches(picker_opts({ layout = { preset = "select" } }))
				end,
				desc = "Pick and Switch Git Branches",
			},
			{
				"<leader>th",
				function()
					picker().colorschemes(picker_opts({ layout = { preset = "ivy" } }))
				end,
				desc = "Pick Color Schemes",
			},
			{
				"<leader>vh",
				function()
					picker().help(picker_opts())
				end,
				desc = "Help Pages",
			},
		},
	},
}

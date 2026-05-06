return {
	"nvim-lualine/lualine.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	event = "VeryLazy",
	config = function()
		local lualine = require("lualine")
		local lazy_status = require("lazy.status")

		local colors = {
			bg = "#011628",
			bg_dark = "#011423",
			bg_highlight = "#143652",
			fg = "#CBE0F0",
			fg_dark = "#B4D0E9",
			blue = "#7AA2F7",
			cyan = "#7DCFFF",
			green = "#9ECE6A",
			orange = "#FF9E64",
			purple = "#BB9AF7",
			red = "#F7768E",
			yellow = "#E0AF68",
		}

		local function mode_color(bg)
			return { fg = colors.bg_dark, bg = bg, gui = "bold" }
		end

		local lualine_theme = {
			normal = {
				a = mode_color(colors.blue),
				b = { fg = colors.fg, bg = colors.bg_highlight },
				c = { fg = colors.fg_dark, bg = colors.bg_dark },
			},
			insert = {
				a = mode_color(colors.green),
				b = { fg = colors.fg, bg = colors.bg_highlight },
			},
			visual = {
				a = mode_color(colors.purple),
				b = { fg = colors.fg, bg = colors.bg_highlight },
			},
			replace = {
				a = mode_color(colors.red),
				b = { fg = colors.fg, bg = colors.bg_highlight },
			},
			command = {
				a = mode_color(colors.yellow),
				b = { fg = colors.fg, bg = colors.bg_highlight },
			},
			inactive = {
				a = { fg = colors.fg_dark, bg = colors.bg_dark, gui = "bold" },
				b = { fg = colors.fg_dark, bg = colors.bg_dark },
				c = { fg = colors.fg_dark, bg = colors.bg_dark },
			},
		}

		local function hide_in_width()
			return vim.fn.winwidth(0) > 80
		end

		local mode = {
			"mode",
			fmt = function(str)
				return " " .. str
			end,
			separator = { right = "" },
			padding = { left = 1, right = 1 },
		}

		local branch = {
			"branch",
			icon = "",
			color = { fg = colors.cyan, gui = "bold" },
		}

		local diff = {
			"diff",
			symbols = { added = " ", modified = " ", removed = " " },
			cond = hide_in_width,
		}

		local diagnostics = {
			"diagnostics",
			sources = { "nvim_diagnostic" },
			symbols = { error = " ", warn = " ", info = " ", hint = "󰠠 " },
			cond = hide_in_width,
		}

		local filename = {
			"filename",
			file_status = true,
			path = 1,
			symbols = {
				modified = " ●",
				readonly = " 󰌾",
				unnamed = "[No Name]",
			},
		}

		local lazy_updates = {
			lazy_status.updates,
			cond = lazy_status.has_updates,
			color = { fg = colors.orange, gui = "bold" },
		}

		local lazy_extension = {
			sections = {
				lualine_a = {
					function()
						return "lazy 💤"
					end,
				},
				lualine_b = {
					function()
						local stats = require("lazy").stats()
						return "loaded: " .. stats.loaded .. "/" .. stats.count
					end,
				},
				lualine_c = { lazy_updates },
				lualine_z = {
					{
						function()
							return os.date("%H:%M")
						end,
						icon = "",
						color = { fg = colors.cyan, gui = "bold" },
					},
				},
			},
			filetypes = { "lazy" },
		}

		lualine.setup({
			options = {
				icons_enabled = true,
				theme = lualine_theme,
				globalstatus = true,
				component_separators = { left = "|", right = "|" },
				section_separators = "",
				disabled_filetypes = {
					statusline = { "snacks_dashboard", "dashboard", "alpha" },
				},
			},
			sections = {
				lualine_a = { mode },
				lualine_b = { branch, diff },
				lualine_c = { filename },
				lualine_x = { diagnostics, lazy_updates, "filetype" },
				lualine_y = { "progress" },
				lualine_z = { "location" },
			},
			inactive_sections = {
				lualine_a = {},
				lualine_b = {},
				lualine_c = { filename },
				lualine_x = { "location" },
				lualine_y = {},
				lualine_z = {},
			},
			extensions = { lazy_extension, "mason", "quickfix", "trouble" },
		})
	end,
}

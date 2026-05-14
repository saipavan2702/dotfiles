return {
	"stevearc/oil.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		require("oil").setup({
			default_file_explorer = true,
			columns = { "icon" },
			keymaps = {
				["<C-h>"] = false,
				["<C-c>"] = false,
				["?"] = "actions.show_help",
				["q"] = "actions.close",
				["h"] = { "actions.select", opts = { horizontal = true } },
				["v"] = { "actions.select", opts = { vertical = true } },
				["t"] = { "actions.select", opts = { tab = true } },
			},
			delete_to_trash = true,
			skip_confirm_for_simple_edits = true,
			view_options = {
				show_hidden = true,
			},
			float = {
				padding = 2,
				max_width = 0.9,
				max_height = 0.85,
				border = "rounded",
				preview_split = "right",
				win_options = {
					winblend = 0,
					winhighlight = "NormalFloat:NormalFloat,FloatBorder:FloatBorder",
				},
				override = function(conf)
					conf.title = " Oil "
					conf.title_pos = "center"
					return conf
				end,
			},
			confirmation = {
				border = "rounded",
			},
			progress = {
				border = "rounded",
				minimized_border = "rounded",
			},
			ssh = {
				border = "rounded",
			},
			keymaps_help = {
				border = "rounded",
			},
		})

		vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })
		vim.keymap.set("n", "<leader>-", require("oil").toggle_float, { desc = "Open parent directory in float" })

		vim.api.nvim_create_autocmd("FileType", {
			pattern = "oil",
			callback = function()
				vim.opt_local.cursorline = true
				vim.opt_local.number = false
				vim.opt_local.relativenumber = false
				vim.opt_local.signcolumn = "no"
			end,
		})
	end,
}

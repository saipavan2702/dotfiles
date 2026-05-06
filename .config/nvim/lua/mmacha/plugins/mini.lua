return {
	{
		"echasnovski/mini.comment",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = { "JoosepAlviste/nvim-ts-context-commentstring" },
		config = function()
			require("ts_context_commentstring").setup({ enable_autocmd = false })

			require("mini.comment").setup({
				options = {
					custom_commentstring = function()
						return require("ts_context_commentstring.internal").calculate_commentstring()
							or vim.bo.commentstring
					end,
				},
			})
		end,
	},
	{
		"echasnovski/mini.surround",
		event = { "BufReadPre", "BufNewFile" },
		opts = {
			mappings = {
				add = "sa",
				delete = "ds",
				find = "sf",
				find_left = "sF",
				highlight = "sh",
				replace = "sr",
				update_n_lines = "sn",
				suffix_last = "l",
				suffix_next = "n",
			},
			n_lines = 20,
			search_method = "cover",
		},
	},
	{
		"echasnovski/mini.trailspace",
		event = { "BufReadPost", "BufNewFile" },
		config = function()
			local trailspace = require("mini.trailspace")
			trailspace.setup({ only_in_normal_buffers = true })

			vim.keymap.set("n", "<leader>cw", function()
				trailspace.trim()
			end, { desc = "Erase Whitespace" })

			vim.api.nvim_create_autocmd("CursorMoved", {
				group = vim.api.nvim_create_augroup("UserMiniTrailspace", { clear = true }),
				callback = function()
					trailspace.unhighlight()
				end,
			})
		end,
	},
	{
		"echasnovski/mini.splitjoin",
		event = { "BufReadPre", "BufNewFile" },
		config = function()
			local splitjoin = require("mini.splitjoin")
			splitjoin.setup({ mappings = { toggle = "" } })

			vim.keymap.set({ "n", "x" }, "sj", function()
				splitjoin.join()
			end, { desc = "Join arguments" })
			vim.keymap.set({ "n", "x" }, "sk", function()
				splitjoin.split()
			end, { desc = "Split arguments" })
		end,
	},
}

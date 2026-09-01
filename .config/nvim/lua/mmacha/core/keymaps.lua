local opts = { noremap = true, silent = true }

vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.keymap.set("n", "<leader><leader>", function()
	vim.cmd("so")
end)

vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "moves lines down in visual selection" })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "moves lines up in visual selection" })

vim.keymap.set("n", "J", "mzJ`z")
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "move down in buffer with cursor centered" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "move up in buffer with cursor centered" })
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

vim.keymap.set("v", "<", "<gv", opts)
vim.keymap.set("v", ">", ">gv", opts)

-- the how it be paste
vim.keymap.set("x", "<leader>p", [["_dP]])

-- remember yanked
vim.keymap.set("v", "p", '"_dp', opts)

-- Copies or Yank to system clipboard
vim.keymap.set("n", "<leader>Y", [["+Y]], opts)

-- The terminal input path can deliver Command-C after a mouse drag. Without an
-- explicit mapping Neovim treats the trailing `c` as the Visual change command,
-- deleting the selection and entering Insert mode. Ignore that automatic event
-- so the selection stays active and the user can choose y, "*y, or "+y.
vim.keymap.set("x", "<D-c>", "<Nop>", {
	desc = "Ignore automatic terminal copy event",
	silent = true,
})

-- leader d delete wont remember as yanked/clipboard when delete pasting
vim.keymap.set({ "n", "v" }, "<leader>d", [["_d]])

-- ctrl c as escape cuz Im lazy to reach up to the esc key
vim.keymap.set("i", "<C-c>", "<Esc>")
vim.keymap.set("n", "<C-c>", ":nohl<CR>", { desc = "Clear search hl", silent = true })
-- Unmaps Q in normal mode
vim.keymap.set("n", "Q", "<nop>")

-- Open the shared project picker in a tmux popup.
vim.keymap.set("n", "<C-f>", function()
	if not vim.env.TMUX or vim.env.TMUX == "" or vim.fn.executable("tmux") == 0 then
		vim.notify("Project picker requires an active tmux session", vim.log.levels.WARN)
		return
	end

	local script = vim.fn.expand("~/.config/tmux/scripts/project-fzf.sh")
	if vim.fn.executable(script) == 0 then
		vim.notify("Project picker is not executable: " .. script, vim.log.levels.ERROR)
		return
	end

	vim.system({
		"tmux",
		"display-popup",
		"-d",
		"#{pane_current_path}",
		"-w",
		"80%",
		"-h",
		"70%",
		"-E",
		script,
	}, { text = true }, function(result)
		if result.code == 0 then
			return
		end

		vim.schedule(function()
			local detail = vim.trim(result.stderr or "")
			local message = "Unable to open tmux project picker"
			if detail ~= "" then
				message = message .. ": " .. detail
			end
			vim.notify(message, vim.log.levels.ERROR)
		end)
	end)
end, { desc = "Open tmux project picker" })

-- prevent x delete from registering when next paste
vim.keymap.set("n", "x", '"_x', opts)

-- Replace the word cursor is on globally
vim.keymap.set(
	"n",
	"<leader>s",
	[[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]],
	{ desc = "Replace word cursor is on globally" }
)

-- Make the current file executable without interpolating its name into a shell command.
vim.keymap.set("n", "<leader>x", function()
	local path = vim.api.nvim_buf_get_name(0)
	if path == "" then
		vim.notify("Save the file before making it executable", vim.log.levels.WARN)
		return
	end

	vim.system({ "chmod", "+x", path }, { text = true }, function(result)
		vim.schedule(function()
			if result.code == 0 then
				vim.notify("Made executable: " .. vim.fn.fnamemodify(path, ":~"))
				return
			end

			local detail = vim.trim(result.stderr or "")
			vim.notify(detail ~= "" and detail or "chmod failed", vim.log.levels.ERROR)
		end)
	end)
end, { desc = "Make current file executable" })

-- Hightlight yanking
vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
	callback = function()
		if vim.hl.hl_op then
			vim.hl.hl_op()
		else
			vim.hl.on_yank()
		end
	end,
})

-- tab stuff
vim.keymap.set("n", "<leader>to", "<cmd>tabnew<CR>") --open new tab
vim.keymap.set("n", "<leader>tx", "<cmd>tabclose<CR>") --close current tab
vim.keymap.set("n", "<leader>tn", "<cmd>tabn<CR>") --go to next
vim.keymap.set("n", "<leader>tp", "<cmd>tabp<CR>") --go to pre
vim.keymap.set("n", "<leader>tf", "<cmd>tabnew %<CR>") --open current tab in new tab

--split management
vim.keymap.set("n", "<leader>sv", "<C-w>v", { desc = "Split window vertically" })
-- split window vertically
vim.keymap.set("n", "<leader>sh", "<C-w>s", { desc = "Split window horizontally" })
-- split window horizontally
vim.keymap.set("n", "<leader>se", "<C-w>=", { desc = "Make splits equal size" }) -- make split windows equal width & height
-- close current split window
vim.keymap.set("n", "<leader>sx", "<cmd>close<CR>", { desc = "Close current split" })

-- Copy filepath to the clipboard
vim.keymap.set("n", "<leader>fp", function()
	local filePath = vim.fn.expand("%:~") -- Gets the file path relative to the home directory
	vim.fn.setreg("+", filePath) -- Copy the file path to the clipboard register
	print("File path copied to clipboard: " .. filePath)
end, { desc = "Copy file path to clipboard" })

-- Toggle LSP diagnostics visibility
local isLspDiagnosticsVisible = true
vim.keymap.set("n", "<leader>lx", function()
	isLspDiagnosticsVisible = not isLspDiagnosticsVisible
	vim.diagnostic.config({
		virtual_text = isLspDiagnosticsVisible,
		underline = isLspDiagnosticsVisible,
	})
end, { desc = "Toggle LSP diagnostics" })

-- vim.g.loaded_netrw = 0
-- vim.g.loaded_netrwPlugin = 0
-- vim.cmd("let g:netrw_liststyle = 3")
-- Disable netrw banner
vim.cmd("let g:netrw_banner = 0")

-- line numbers
vim.opt.nu = true
vim.opt.relativenumber = true

-- editing behavior
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.termguicolors = true
vim.opt.cursorline = true
vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.confirm = true
vim.opt.showmode = false
vim.opt.timeoutlen = 300

-- indentation
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.wrap = false

-- Keep code buffers unwrapped by default; enable text wrapping per filetype if needed

-- backup and undo
vim.opt.swapfile = false
vim.opt.backup = false
local undodir = vim.fn.expand("~/.vim/undodir")
if vim.fn.isdirectory(undodir) == 0 then
    vim.fn.mkdir(undodir, "p")
end
vim.opt.undodir = undodir
vim.opt.undofile = true

-- search
vim.opt.inccommand = "split"
vim.opt.hlsearch = true

-- UI
vim.opt.background = "dark"
vim.opt.laststatus = 3
vim.opt.showtabline = 1
vim.opt.pumheight = 12

local function tabpage_title(tab)
    local ok, title = pcall(vim.api.nvim_tabpage_get_var, tab, "tab_title")
    if ok and type(title) == "string" and title ~= "" then
        return title
    end

    local win = vim.api.nvim_tabpage_get_win(tab)
    local buf = vim.api.nvim_win_get_buf(win)
    local name = vim.api.nvim_buf_get_name(buf)

    if name == "" then
        return "[No Name]"
    end

    local tail = vim.fn.fnamemodify(name, ":t")
    if tail ~= "" then
        return tail
    end

    return vim.fn.fnamemodify(name, ":h:t")
end

function _G.mmacha_tabline()
    local items = {}

    for index, tab in ipairs(vim.api.nvim_list_tabpages()) do
        local is_current = tab == vim.api.nvim_get_current_tabpage()
        items[#items + 1] = "%" .. index .. "T"
        items[#items + 1] = is_current and "%#TabLineSel#" or "%#TabLine#"
        items[#items + 1] = " " .. index .. ":" .. tabpage_title(tab) .. " "
    end

    items[#items + 1] = "%#TabLineFill#%T"
    return table.concat(items)
end

vim.opt.tabline = "%!v:lua.mmacha_tabline()"

-- folding (for nvim-ufo)
vim.o.foldenable = true
vim.o.foldmethod = "manual"
vim.o.foldlevel = 99
vim.o.foldcolumn = "0"

-- window splits
vim.opt.splitright = true
vim.opt.splitbelow = true

-- misc
vim.opt.guicursor = ""
vim.opt.isfname:append("@-@")
vim.opt.updatetime = 50
vim.opt.colorcolumn = ""
vim.opt.clipboard:append("unnamedplus")
vim.opt.mouse = "a"

vim.api.nvim_create_autocmd("FileType", {
    pattern = { "gitcommit", "markdown", "text" },
    callback = function()
        vim.opt_local.wrap = true
        vim.opt_local.linebreak = true
        vim.opt_local.spell = true
        vim.opt_local.textwidth = 80
    end,
})

vim.api.nvim_create_autocmd("BufReadPost", {
    callback = function()
        local mark = vim.api.nvim_buf_get_mark(0, '"')
        local line_count = vim.api.nvim_buf_line_count(0)
        if mark[1] > 0 and mark[1] <= line_count then
            pcall(vim.api.nvim_win_set_cursor, 0, mark)
        end
    end,
})

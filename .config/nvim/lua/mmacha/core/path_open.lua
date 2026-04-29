local M = {}

local function trim(value)
    return (value or ""):gsub("^%s+", ""):gsub("%s+$", "")
end

local function strip(raw)
    raw = trim(raw)
    raw = raw:gsub("^%[.-%]%((.-)%)$", "%1")
    raw = raw:gsub("^<", ""):gsub(">$", "")
    raw = raw:gsub("^[%(,%s\"'`]+", "")
    raw = raw:gsub("[\"'`%)%],;]+$", "")
    raw = raw:gsub("#.*$", ""):gsub("%?.*$", "")

    if raw == "" or raw:match("^https?://") then
        return nil
    end

    raw = raw:gsub("^file://", "")
    local path, line = raw:match("^(.-):(%d+):?%d*$")
    if path and path ~= "" then
        raw = path
        return vim.fn.expand(raw), tonumber(line)
    end

    return vim.fn.expand(raw), nil
end

local function add(list, seen, value)
    if not value or value == "" or seen[value] then
        return
    end
    seen[value] = true
    table.insert(list, value)
end

local function current_dir()
    local name = vim.api.nvim_buf_get_name(0)
    if name ~= "" then
        return vim.fs.dirname(name)
    end
    return vim.uv.cwd()
end

local function roots()
    local result = { current_dir(), vim.uv.cwd() }
    local git_root = vim.fs.root(0, { ".git" })
    if git_root then
        table.insert(result, git_root)
    end
    return result
end

local function clean_dir(raw)
    local path = strip(raw)
    if not path then
        return nil
    end
    return path:gsub("/+$", "")
end

local function buffer_lines_for_context()
    local cursor = vim.api.nvim_win_get_cursor(0)[1]
    local start = math.max(cursor - 25, 0)
    local finish = math.min(cursor + 25, vim.api.nvim_buf_line_count(0))
    return vim.api.nvim_buf_get_lines(0, start, finish, false)
end

local function context_dirs()
    local result, seen = {}, {}

    for _, line in ipairs(buffer_lines_for_context()) do
        for dir in line:gmatch("%-%-tmpdir%s+([^%s]+)") do
            add(result, seen, clean_dir(dir))
        end
        for dir in line:gmatch("tmpdir is%s+([^,%s%)]+)") do
            add(result, seen, clean_dir(dir))
        end
        for dir in line:gmatch("Started main, tmpdir is%s+([^,%s%)]+)") do
            add(result, seen, clean_dir(dir))
        end
        for token in line:gmatch("/[%w%._~/%-]+") do
            token = clean_dir(token)
            if token then
                local stat = vim.uv.fs_stat(token)
                if stat and stat.type == "directory" then
                    add(result, seen, token)
                else
                    add(result, seen, vim.fs.dirname(token))
                end
            end
        end
    end

    return result
end

function M.resolve(raw)
    local path, line = strip(raw)
    if not path then
        return nil
    end

    local candidates = {}
    if path:sub(1, 1) == "/" then
        candidates = { path }
    else
        for _, root in ipairs(roots()) do
            table.insert(candidates, vim.fs.joinpath(root, path))
        end
        if not path:find("/") then
            for _, dir in ipairs(context_dirs()) do
                table.insert(candidates, vim.fs.joinpath(dir, path))
            end
        end
    end

    for _, candidate in ipairs(candidates) do
        local stat = vim.uv.fs_stat(candidate)
        if stat then
            return { path = candidate, line = line, type = stat.type }
        end
    end

    if not path:find("/") then
        local seen = {}
        for _, root in ipairs({ current_dir(), vim.uv.cwd() }) do
            if root and root ~= "" and not seen[root] then
                seen[root] = true
                local found = vim.fs.find(path, { path = root, type = "file", limit = 1 })[1]
                if found then
                    return { path = found, line = line, type = "file" }
                end
            end
        end
    end
end

local function under_cursor()
    local line = vim.api.nvim_get_current_line()
    local col = vim.api.nvim_win_get_cursor(0)[2] + 1
    local start = 1

    while true do
        local s, e, target = line:find("%b[]%(([^)]+)%)", start)
        if not s then
            break
        end
        if col >= s and col <= e then
            return target
        end
        start = e + 1
    end

    local token = vim.fn.expand("<cfile>")
    if token ~= "" then
        return token
    end

    start = 1
    while true do
        local s, e = line:find("[%w%._~/%-]+[%w%._~/%-%:@]*", start)
        if not s then
            break
        end
        if col >= s and col <= e then
            return line:sub(s, e)
        end
        start = e + 1
    end
end

local function jump(line)
    if line then
        pcall(vim.api.nvim_win_set_cursor, 0, { line, 0 })
    end
end

function M.preview(target)
    if target.type == "directory" then
        return M.open("edit", target.path)
    end

    local ok, lines = pcall(vim.fn.readfile, target.path, "", 600)
    if not ok then
        return M.open("edit", target.path)
    end

    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.api.nvim_set_option_value("modifiable", false, { buf = buf })
    vim.api.nvim_set_option_value("filetype", vim.filetype.match({ filename = target.path }) or "", { buf = buf })

    local width = math.floor(vim.o.columns * 0.8)
    local height = math.floor(vim.o.lines * 0.7)
    local win = vim.api.nvim_open_win(buf, true, {
        relative = "editor",
        row = math.floor((vim.o.lines - height) / 2),
        col = math.floor((vim.o.columns - width) / 2),
        width = width,
        height = height,
        border = "rounded",
        title = " " .. vim.fn.fnamemodify(target.path, ":~:.") .. " ",
        title_pos = "center",
    })

    vim.api.nvim_set_option_value("number", true, { win = win })
    local line_count = math.max(vim.api.nvim_buf_line_count(buf), 1)
    jump(math.min(target.line or 1, line_count))
end

function M.open(action, raw)
    local target = type(raw) == "table" and raw or M.resolve(raw or under_cursor())
    if not target then
        vim.notify("No readable file path found under cursor", vim.log.levels.WARN)
        return
    end

    if action == "preview" then
        return M.preview(target)
    end

    local cmd = ({ tab = "tabedit", split = "split", vsplit = "vsplit" })[action] or "edit"
    vim.cmd(cmd .. " " .. vim.fn.fnameescape(target.path))
    jump(target.line)
end

function M.pick_buffer_refs()
    local seen, choices = {}, {}

    local function add(raw)
        local target = M.resolve(raw)
        if not target then
            return
        end

        local key = target.path .. ":" .. (target.line or "")
        if seen[key] then
            return
        end

        seen[key] = true
        table.insert(choices, {
            target = target,
            label = vim.fn.fnamemodify(target.path, ":~:.") .. (target.line and ":" .. target.line or ""),
        })
    end

    for _, line in ipairs(vim.api.nvim_buf_get_lines(0, 0, -1, false)) do
        for target in line:gmatch("%b[]%(([^)]+)%)") do
            add(target)
        end
        for token in line:gmatch("[%w%._~/%-]+[%w%._~/%-%:@]*") do
            add(token)
        end
    end

    if #choices == 0 then
        vim.notify("No readable file references found in this buffer", vim.log.levels.INFO)
        return
    end

    vim.ui.select(choices, {
        prompt = "Open file reference",
        format_item = function(item)
            return item.label
        end,
    }, function(item)
        if item then
            M.open("edit", item.target)
        end
    end)
end

return M

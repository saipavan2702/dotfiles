local function tailwind_icon(ctx)
    local item = { word = ctx.label, kind = ctx.kind_icon, kind_hl_group = ctx.kind_hl }
    if ctx.source_id == "lsp" then
        item = require("tailwindcss-colorizer-cmp").formatter({ source = { name = "nvim_lsp" } }, item)
    end
    return item
end

return {
    "saghen/blink.cmp",
    branch = "main",
    version = "1.*",
    event = "InsertEnter",
    dependencies = {
        {
            "L3MON4D3/LuaSnip",
            version = "v2.*",
            build = "make install_jsregexp",
            config = function()
                require("luasnip.loaders.from_vscode").lazy_load()
            end,
        },
        "rafamadriz/friendly-snippets",
        "ribru17/blink-cmp-spell",
        "roobert/tailwindcss-colorizer-cmp.nvim",
    },
    opts = {
        enabled = function()
            return vim.bo.buftype ~= "prompt" and vim.b.completion ~= false
        end,
        keymap = {
            preset = "none",
            ["<C-b>"] = { "scroll_documentation_up", "fallback" },
            ["<C-f>"] = { "scroll_documentation_down", "fallback" },
            ["<C-e>"] = { "cancel", "fallback" },
            ["<C-Space>"] = { "show", "fallback" },
            ["<CR>"] = { "accept", "fallback" },
            ["<C-y>"] = { "select_and_accept", "fallback" },
            ["<C-j>"] = { "select_next", "fallback" },
            ["<C-k>"] = { "select_prev", "fallback" },
            ["<C-n>"] = { "select_next", "fallback" },
            ["<C-p>"] = { "select_prev", "fallback" },
            ["<Up>"] = { "select_prev", "fallback" },
            ["<Down>"] = { "select_next", "fallback" },
            ["<Tab>"] = {
                "select_next",
                function()
                    local luasnip = require("luasnip")
                    if luasnip.expand_or_locally_jumpable() then
                        luasnip.expand_or_jump()
                        return true
                    end
                end,
                function(cmp)
                    local col = vim.api.nvim_win_get_cursor(0)[2]
                    if col > 0 and vim.api.nvim_get_current_line():sub(col, col):match("%S") then
                        return cmp.show()
                    end
                end,
                "fallback",
            },
            ["<S-Tab>"] = {
                "select_prev",
                function()
                    local luasnip = require("luasnip")
                    if luasnip.locally_jumpable(-1) then
                        luasnip.jump(-1)
                        return true
                    end
                end,
                "fallback",
            },
        },
        snippets = { preset = "luasnip" },
        completion = {
            list = { selection = { preselect = false, auto_insert = true } },
            menu = {
                border = "rounded",
                draw = {
                    components = {
                        kind_icon = {
                            text = function(ctx)
                                return tailwind_icon(ctx).kind .. ctx.icon_gap
                            end,
                            highlight = function(ctx)
                                return tailwind_icon(ctx).kind_hl_group
                            end,
                        },
                    },
                },
            },
            documentation = { auto_show = true, window = { border = "rounded" } },
        },
        sources = {
            default = { "lsp", "lazydev", "snippets", "path", "spell", "buffer" },
            providers = {
                lazydev = {
                    name = "LazyDev",
                    module = "lazydev.integrations.blink",
                    score_offset = 100,
                    enabled = function()
                        return vim.bo.filetype == "lua"
                    end,
                },
                spell = {
                    name = "Spell",
                    module = "blink-cmp-spell",
                    enabled = function()
                        return vim.tbl_contains({ "markdown", "text" }, vim.bo.filetype)
                    end,
                },
                buffer = { min_keyword_length = 3 },
            },
        },
        fuzzy = { implementation = "prefer_rust_with_warning" },
        cmdline = { enabled = false },
        signature = { enabled = false },
    },
}

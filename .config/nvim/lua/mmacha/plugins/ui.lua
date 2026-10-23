return {
    {
        "Amansingh-afk/milli.nvim",
        enabled = false, -- Saved for later; no dashboard or screensaver integration.
    },
    {
        "Bekaboo/dropbar.nvim",
        lazy = false,
        opts = {},
        keys = {
            {
                "<leader>;",
                function()
                    require("dropbar.api").pick()
                end,
                desc = "Pick breadcrumb",
            },
        },
    },
    {
        "folke/which-key.nvim",
        event = "VeryLazy",
        opts = {
            preset = "helix",
            spec = {
                { "<leader>o", group = "open" },
                { "<leader>p", group = "pick/search" },
                { "<leader>t", group = "tabs/theme" },
                { "<leader>s", group = "split/replace" },
                { "<leader>g", group = "git" },
                { "<leader>l", group = "lsp" },
                { "<leader>w", group = "workspace" },
            },
        },
    },
}

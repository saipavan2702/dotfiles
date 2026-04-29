return {
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
            },
        },
    },
    {
        "stevearc/dressing.nvim",
        event = "VeryLazy",
        opts = {
            input = { border = "rounded" },
            select = { backend = { "telescope", "builtin" } },
        },
    },
}

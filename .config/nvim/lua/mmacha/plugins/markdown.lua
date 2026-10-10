return {
    {
        "MeanderingProgrammer/render-markdown.nvim",
        ft = { "markdown" },
        dependencies = {
            "nvim-treesitter/nvim-treesitter",
            "nvim-tree/nvim-web-devicons",
        },
        opts = {
            file_types = { "markdown" },
            anti_conceal = {
                enabled = true,
            },
        },
    },
    {
        "axieax/urlview.nvim",
        cmd = "UrlView",
        keys = {
            { "<leader>pu", "<cmd>UrlView<CR>", desc = "View URLs in current buffer" },
            { "<leader>pU", "<cmd>UrlView lazy<CR>", desc = "View plugin URLs from lazy.nvim" },
        },
        opts = {
            default_picker = "native",
        },
    },
}

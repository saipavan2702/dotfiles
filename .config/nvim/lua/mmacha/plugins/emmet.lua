return {
    -- here only for wrapping html tags
    -- emmet_ls is already installed in mason
    "olrtg/nvim-emmet",
    keys = {
        {
            "<leader>xe",
            function()
                require("nvim-emmet").wrap_with_abbreviation()
            end,
            mode = { "n", "v" },
            desc = "Wrap with Emmet abbreviation",
        },
    },
}

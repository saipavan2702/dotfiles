return {
    "rmagatti/auto-session",
    event = "VeryLazy",
    config = function()
        local auto_session = require("auto-session")

        auto_session.setup({
            auto_restore = false,
            suppressed_dirs = { "~/", "~/Dev/", "~/Downloads", "~/Documents", "~/Desktop/" },
            session_lens = {
                picker = "snacks",
                load_on_setup = false,
            },
        })

        local keymap = vim.keymap
        keymap.set("n", "<leader>wr", "<cmd>AutoSession restore<CR>", { desc = "Restore session for cwd" })
        keymap.set("n", "<leader>ws", "<cmd>AutoSession save<CR>", { desc = "Save session for cwd" })
        keymap.set("n", "<leader>wl", "<cmd>AutoSession search<CR>", { desc = "Find saved sessions" })
    end,
}

return {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
        local configs = require("nvim-treesitter")

        configs.setup({
            -- Add languages you want automatically installed
            ensure_installed = {
                "vimdoc",
                "lua",
                "bash",
                "c_sharp",
                "javascript",
                "typescript",
                "cpp",
                "c",
                "java",
            },

            -- Enable key features
            highlight = { enable = true },
            indent = { enable = true },
        })
    end
}

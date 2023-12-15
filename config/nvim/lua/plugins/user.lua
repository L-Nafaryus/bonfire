return {

    {
        "ellisonleao/gruvbox.nvim",
    },

    {
        "folke/tokyonight.nvim",
        style = "moon",
        priority = 1000,
    },

    { "skywind3000/asyncrun.vim" },

    -- Configure LazyVim to load gruvbox
    {
        "LazyVim/LazyVim",
        opts = {
            colorscheme = "tokyonight",
        },
    },

    { "equalsraf/neovim-gui-shim" },

    {
        "nvim-neo-tree/neo-tree.nvim",
        opts = {
            filesystem = {
                filtered_items = {
                    hide_dotfiles = false,
                    hide_gitignored = false,
                },
                use_libuv_file_watcher = true,
            },
        },
    },

    {
        "folke/trouble.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
    },

    {
        "nvim-orgmode/orgmode",
        dependencies = {
            { "nvim-treesitter/nvim-treesitter", lazy = true },
        },
        event = "VeryLazy",
        config = function()
            require("orgmode").setup_ts_grammar()

            require("nvim-treesitter.configs").setup({
                highlight = {
                    enable = true,
                    additional_vim_regex_highlighting = { "org" },
                },
                ensure_installed = { "org" },
            })

            require("orgmode").setup()
        end,
    },
}

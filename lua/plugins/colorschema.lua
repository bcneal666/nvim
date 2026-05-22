return {
  {
    "projekt0n/github-nvim-theme",
    lazy = false,    -- 必須立即載入，不能 lazy
    priority = 1000, -- 比其他插件優先載入
    config = function()
      require("github-theme").setup({})
    end,
  },
  {
    "LazyVim/LazyVim",
    opts = { colorscheme = "github_dark_high_contrast" },
  },
}

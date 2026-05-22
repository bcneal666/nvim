return {
  {
    "scottmckendry/cyberdream.nvim",
    lazy = false,    -- 必須立即載入，不能 lazy
    priority = 1000, -- 比其他插件優先載入
    opts = {
      transparent = false, -- 背景透明（若終端支援可改 true）
      italic_comments = true,
      hide_fillchars = false,
      borderless_telescope = true,
      terminal_colors = true,
    },
  },
  {
    "LazyVim/LazyVim",
    opts = { colorscheme = "cyberdream" },
  },
}

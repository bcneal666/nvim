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
      colors = {
        fg = "#00ff00", -- 覆寫 palette fg，所有引用 t.fg 的 group 一併生效
      },
      highlights = {
        Normal = { fg = "#00ff00" },
        ["@markup"] = { fg = "#00ff00" },   -- treesitter markdown body (nvim 0.10+)
        ["@text"] = { fg = "#00ff00" },     -- treesitter markdown body (舊版)
        ["@markup.raw"] = { fg = "#00ff00" }, -- raw/literal text
      },
    },
  },
  {
    "LazyVim/LazyVim",
    opts = { colorscheme = "cyberdream" },
  },
}

return {
  "folke/snacks.nvim",
  opts = {
    picker = {
      sources = {
        explorer = {
          hidden = true, -- 顯示 . 開頭檔
          ignored = false, -- gitignore 命中的仍隱藏（node_modules / dist）
          include = { ".env*" }, -- 優先權最高，打穿 hidden + ignored
        },
      },
    },
  },
}

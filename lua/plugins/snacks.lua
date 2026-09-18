return {
  "folke/snacks.nvim",
  opts = {
    picker = {
      sources = {
        explorer = {
          hidden = true, -- 顯示 . 開頭檔
          -- gitignore 命中的也顯示（node_modules / dist），
          -- 含 .git —— snacks 在 explorer/git.lua 把 .git 標成 "!!" 當 ignored 處理
          ignored = true,
          include = { ".env*" }, -- 優先權最高，打穿 hidden + ignored
        },
      },
    },
  },
}

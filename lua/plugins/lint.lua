return {
  "mfussenegger/nvim-lint",
  opts = {
    linters = {
      ["markdownlint-cli2"] = {
        -- stdpath("config") 跨平台正確：Windows=~/AppData/Local/nvim、Linux=~/.config/nvim。
        -- 原本寫死 ~/.config/nvim，Windows 下找不到 → .markdownlint.json 被忽略。
        cwd = vim.fn.stdpath("config"),
      },
    },
  },
}

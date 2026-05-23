return {
  "mfussenegger/nvim-lint",
  opts = {
    linters = {
      ["markdownlint-cli2"] = {
        cwd = vim.fn.expand("~/.config/nvim"),
      },
    },
  },
}

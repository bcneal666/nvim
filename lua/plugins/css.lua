-- CSS / SCSS 完整語言支援
-- 解決問題：
--   1. 語法高亮：確保 CSS Treesitter parser 已安裝
--   2. 顏色提示：啟用 cssls LSP + 顏色色塊預覽插件
return {
  -- 1. Treesitter：確保 CSS / SCSS 語法解析器已安裝（提供語法高亮）
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "css", "scss" })
    end,
  },

  -- 2. Mason：自動安裝 CSS Language Server
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "css-lsp" })
    end,
  },

  -- 3. LSP：啟用 cssls（提供 IntelliSense、錯誤診斷、內建顏色提示）
  --    unknownAtRules = "ignore"：消除 Tailwind v4 新語法（@plugin、@custom-variant、@theme）的誤報警告
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        cssls = {
          settings = {
            css = {
              lint = { unknownAtRules = "ignore" },
            },
            scss = {
              lint = { unknownAtRules = "ignore" },
            },
            less = {
              lint = { unknownAtRules = "ignore" },
            },
          },
        },
      },
    },
  },

  -- 4. 顏色色塊預覽：在 #fff、rgb()、hsl() 等顏色值旁顯示視覺色塊
  {
    "brenoprata10/nvim-highlight-colors",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      render = "background",  -- 以顏色值本身的背景顯示色塊（最直觀）
      enable_tailwind = true, -- 同時支援 Tailwind CSS class 顏色預覽
    },
  },
}

-- VPS 記憶體吃緊：封頂 vtsls 的 tsserver 記憶體，避免單一 LSP 撐爆 RAM 拖垮主機。
-- 只覆寫此欄位，其餘沿用 lang.typescript 預設（Lazy.nvim 會合併）。
-- setup.vtsls 會把 typescript 設定複製到 javascript，故 cap 兩邊皆生效。
return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      vtsls = {
        settings = {
          typescript = {
            tsserver = { maxTsServerMemory = 1024 },
          },
        },
      },
    },
  },
}

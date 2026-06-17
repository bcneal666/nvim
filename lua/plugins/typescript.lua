-- vtsls 的 tsserver 記憶體上限依機器調整：
--   少核（VPS 2 核、RAM 吃緊）→ 封頂 1024MB，避免單一 LSP 撐爆 RAM 拖垮主機。
--   多核（Windows 工作站，RAM 充足）→ 抬到 4096MB，大型 TS/TSX 專案不再因 GC 抖動而編輯卡。
-- 只覆寫此欄位，其餘沿用 lang.typescript 預設（Lazy.nvim 會合併）。
-- setup.vtsls 會把 typescript 設定複製到 javascript，故 cap 兩邊皆生效。
local low_spec = ((vim.uv or vim.loop).available_parallelism and (vim.uv or vim.loop).available_parallelism() or 8) <= 4

return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      vtsls = {
        settings = {
          typescript = {
            tsserver = { maxTsServerMemory = low_spec and 1024 or 4096 },
          },
        },
      },
    },
  },
}

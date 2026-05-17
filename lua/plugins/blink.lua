-- 讓 Tab 確認 blink.cmp 的補全（包含 Codeium、LSP 與 snippet）。
-- LazyVim 預設 preset = "enter"，Tab 無法接受 Codeium 在 cmp 選單中的建議。
-- 改成 super-tab 後，LazyVim 的 blink config（extras/coding/blink.lua:127）
-- 會自動把 <Tab> 串上 select_and_accept / snippet_forward / ai_nes / ai_accept / fallback。
-- 預設的 ["<C-y>"] = { "select_and_accept" } 仍透過 deep merge 保留，可當 Enter 確認的備援。
return {
  {
    "saghen/blink.cmp",
    opts = {
      keymap = {
        preset = "super-tab",
      },
    },
  },
}

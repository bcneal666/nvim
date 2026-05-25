-- blink.cmp：LSP / Tailwind 補全
-- Tab 拔掉還給 Codeium ghost text；Enter 接受 LSP 建議
return {
  {
    "saghen/blink.cmp",
    opts = {
      keymap = {
        preset = "default",
        ["<Tab>"] = {},              -- Tab 還給 Codeium
        ["<S-Tab>"] = {},            -- S-Tab 一起拔
        ["<CR>"] = { "accept", "fallback" },
      },
    },
  },
}

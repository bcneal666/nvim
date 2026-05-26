-- blink.cmp：LSP / Tailwind 補全 popup
-- 設計：blink popup（LSP / Tailwind class）+ Codeium ghost text 並存
--   Tab 留給 Codeium ghost text 接受；blink popup 用 <CR> 或方向鍵操作
return {
  {
    "saghen/blink.cmp",
    opts = {
      keymap = {
        preset = "default",
        -- Tab 還給 Codeium ghost text；blink popup 透過 <CR> 或方向鍵操作
        ["<Tab>"] = {},
        ["<S-Tab>"] = {},
        -- <CR> 已選候選 → accept；沒選 → fallback 換行
        ["<CR>"] = { "accept", "fallback" },
        -- 手動觸發 popup（auto_show 預設已開，這條是保險）
        ["<C-Space>"] = { "show", "show_documentation", "hide_documentation" },
      },
      completion = {
        -- 顯式宣告：輸入關鍵字時自動 popup（blink 預設值，重寫一次避免被其他 extra 蓋掉）
        menu = { auto_show = true },
        trigger = { show_on_keyword = true, show_on_trigger_character = true },
        -- popup 出來不預選第一項，避免 <CR> 沒看清楚就誤選
        list = { selection = { preselect = false, auto_insert = false } },
      },
    },
  },
}

-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- 關閉 markdown / text 的拼字檢查
vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- 關閉 vtsls 的 LSP semantic tokens：它每次 buffer 變更會重跑一遍語意上色，
-- 疊在 treesitter 高亮之上 → 大型 TS/TSX 每次編輯多一次 ~16ms 量級的重高亮。
-- treesitter 已提供足夠著色；關掉只省重繪，補全 / 診斷 / hover 不受影響。
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("user_vtsls_no_semantic_tokens", { clear = true }),
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client and client.name == "vtsls" then
      client.server_capabilities.semanticTokensProvider = nil
    end
  end,
})

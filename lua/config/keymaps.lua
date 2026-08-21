-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- jj 逃出 insert 模式：與 Claude Code 的 vim editorMode 對齊肌肉記憶。
-- 純 nvim 層映射，不涉終端機跳脫序列，Windows Terminal / ghostty / SSH 行為一致。
-- 觸發窗口受 timeoutlen 約束（LazyVim 預設 300ms，本 repo 未覆寫）。
vim.keymap.set("i", "jj", "<Esc>", { desc = "離開 insert 模式" })

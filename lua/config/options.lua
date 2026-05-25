-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.opt.conceallevel = 0 -- 顯示完整 markdown 語法符號（不隱藏 ** / # 等）
vim.opt.wrap = true      -- 超出視窗寬度的程式碼自動換行顯示
vim.opt.linebreak = true -- 換行點對齊單字邊界（不在單字中間斷行）
vim.opt.fileformat = "unix"   -- 存檔強制用 LF，避免 Codeium 生成碼混入 ^M

-- Windows：優先使用 WinLibs(gcc)，clang 作為備援
-- LazyVim 的 treesitter 健康檢查只認 gcc / cl，不認 clang
if vim.fn.has("win32") == 1 then
  if vim.fn.executable("gcc") == 1 then
    vim.env.CC = "gcc"
  elseif vim.fn.executable("clang") == 1 then
    -- clang 需要有 MSVC 或 MinGW 的 header，單獨使用可能編譯失敗
    vim.env.CC = "clang"
  end
end

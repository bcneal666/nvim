-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

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

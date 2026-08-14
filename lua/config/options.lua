-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- 停用 sql ftplugin 內建 omni 補全鍵位：其映射呼叫 sqlcomplete#DrillIntoTable /
-- DrillOutOfColumns，在游標移動時觸發卻報 E117 Unknown function（LazyVim #6979）
vim.g.omni_sql_no_default_maps = 1

vim.opt.conceallevel = 0 -- 顯示完整 markdown 語法符號（不隱藏 ** / # 等）
vim.opt.wrap = true -- 超出視窗寬度的程式碼自動換行顯示
vim.opt.linebreak = true -- 換行點對齊單字邊界（不在單字中間斷行）
vim.opt.fileformat = "unix" -- 存檔強制用 LF，避免 Codeium 生成碼混入 ^M

-- 限制 ShaDa：原本累積到 335KB，啟動讀取 ~23ms、編輯期週期性寫入會微停頓。
-- 100 檔歷史、每暫存器 50 行、單項上限 10KB、不存 hlsearch。
vim.opt.shada = "'100,<50,s10,h"

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

-- Linux/VPS：記憶體吃緊時抬高 nvim 及其子程序（LSP、treesitter 編譯）的 oom_score_adj，
-- 讓 earlyoom / OOM-killer 優先殺編輯器而非生產服務（n8n / mongod / PM2 bots）。
-- 子程序 fork 時繼承此值，故開檔噴出的 vtsls 等自動帶到。
if vim.fn.has("linux") == 1 then
  pcall(vim.fn.writefile, { "500" }, "/proc/" .. vim.fn.getpid() .. "/oom_score_adj")
end

-- prettier 只在專案有設定檔（.prettierrc / package.json 的 prettier 欄位等）時才格式化，
-- 避免對沒用 prettier 的專案套用預設風格。跨機器（Windows / Linux VPS）通用，無需平台分支。
vim.g.lazyvim_prettier_needs_config = true

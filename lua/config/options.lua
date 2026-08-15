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

-- SSH session 走 OSC 52：nvim 送跳脫序列給終端機，由終端機寫入「本機」剪貼簿，
-- VPS 沒有 X11/Wayland 也能把 "+y 的內容帶回本機。
-- 本機執行時此段不觸發，沿用 nvim 內建偵測（Wayland/X11 → wl-copy / xclip）。
-- paste 刻意讀 nvim 自身 register：vim.ui.clipboard.osc52 的 paste 會阻塞等終端機
-- 回應最長 10 秒，且多數終端機的剪貼簿讀取需逐次授權。
if vim.env.SSH_TTY or vim.env.SSH_CONNECTION then
  local osc52 = require("vim.ui.clipboard.osc52")
  local function paste()
    return { vim.fn.split(vim.fn.getreg(""), "\n"), vim.fn.getregtype("") }
  end
  vim.g.clipboard = {
    name = "OSC 52",
    copy = { ["+"] = osc52.copy("+"), ["*"] = osc52.copy("*") },
    paste = { ["+"] = paste, ["*"] = paste },
  }

  -- clipboard 選項在 SSH 下被 LazyVim 設為空字串（其 options.lua），故 y 只寫 unnamed
  -- register，不會觸發上面的 OSC 52 copy。這裡只把「yank」鏡射到 +，
  -- 讓 v→y 直接回本機；d / x / c 仍不送出，避免刪除污染本機剪貼簿與多餘的 base64 流量。
  vim.api.nvim_create_autocmd("TextYankPost", {
    group = vim.api.nvim_create_augroup("user_osc52_yank", { clear = true }),
    callback = function()
      local ev = vim.v.event
      if ev.operator == "y" and ev.regname == "" then
        vim.fn.setreg("+", ev.regcontents, ev.regtype)
      end
    end,
  })
end

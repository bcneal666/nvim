-- Codeium 行內建議（ghost text），模仿 VSCode Copilot 體驗
-- 不使用 blink.cmp / nvim-cmp，純粹用 Codeium ghost text
return {
  {
    "Exafunction/codeium.nvim",
    opts = {
      enable_cmp_source = false, -- 不需要 cmp 整合
      virtual_text = {
        enabled = true,
        key_bindings = {
          accept = "<Tab>",      -- Tab：接受整個建議
          accept_word = "<M-w>", -- Alt+W：只接受一個單字
          next = "<M-]>",        -- Alt+]：切換下一個建議
          prev = "<M-[>",        -- Alt+[：切換上一個建議
          dismiss = "<C-]>",     -- Ctrl+]：取消建議
        },
      },
    },
    config = function(_, opts)
      -- Windows 磁碟機代號大小寫不一致的 workaround：
      -- 語言伺服器（Go）在計算相對路徑時，C: 與 c: 被視為不同磁碟機而 panic，
      -- 導致 HTTP response 為空，curl 回報 exit_code=52。
      -- 在此統一把磁碟機代號正規化為大寫，避免 panic。
      local util = require("codeium.util")
      local codeium_io = require("codeium.io")
      util.get_uri = function(path)
        local info = codeium_io.get_system_info()
        if info.is_windows then
          path = path:gsub("\\", "/")
          path = path:gsub("^(%a):", function(c) return c:upper() .. ":" end)
          return "file:///" .. path
        end
        return "file://" .. path
      end
      require("codeium").setup(opts)

      -- 修正 Windows CRLF bug：Codeium 語言伺服器回傳的補全文字夾帶 \r，
      -- 插入後會出現 ^M。在 handle_completions 攔截並過濾掉 \r。
      local vt = require("codeium.virtual_text")
      local orig_handle = vt.handle_completions
      vt.handle_completions = function(items)
        if items then
          for _, item in ipairs(items) do
            if item.completion and item.completion.text then
              item.completion.text = item.completion.text:gsub("\r", "")
            end
          end
        end
        return orig_handle(items)
      end
    end,
  },
}

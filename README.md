# 💤 LazyVim 個人設定

基於 [LazyVim](https://github.com/LazyVim/LazyVim) 的 Neovim 設定：blink.cmp 補全 popup、
Cyberdream 配色、Web 開發完整 LSP。跨 Windows 工作站與 Linux VPS 同步使用
（`git push` / `git pull`）。

## 特色

- **blink.cmp** 負責補全 popup（LSP 候選、Tailwind class）
- **Cyberdream** 主題，前景覆寫為亮綠 `#00ff00`
- **fzf-lua** 取代 Telescope、**snacks.explorer** 取代 neo-tree
- 依 CPU 核數自動調整：vtsls 記憶體上限（≤4 核 1024MB／多核 4096MB）、lazy.nvim 安裝並發數
  （≤4 核降為 2），同一份設定同時適用 VPS 與工作站
- **Windows 相容**：GCC/Clang 自動偵測
- **SSH session** 自動切換剪貼簿走 OSC 52，yank 自動鏡射回本機 `+` 暫存器；tmux 內另需設 `set-clipboard on`，細節見 [CLAUDE.md](./CLAUDE.md#剪貼簿本機-vs-ssh)

## 需求

- Neovim（LazyVim 最新需求版本，見 `:checkhealth`）
- `git`、`gcc` 或 `clang`（Treesitter 編譯 parser）
- `fzf`、`ripgrep`、`fd`（fzf-lua 搜尋）
- `node` + `npm`（TS/Tailwind/Solidity LSP、markdown-preview、prettier）
- `wl-clipboard`（Wayland）或 `xclip`（X11）：本機剪貼簿 provider，缺了 `y` 無法同步到系統剪貼簿

Windows 上述工具可用 `winget` 安裝；Linux 系統層依賴完整清單見 [CLAUDE.md](./CLAUDE.md#linux-環境依賴)。

## 安裝

```bash
# Linux / macOS
git clone https://github.com/bcneal666/nvim.git ~/.config/nvim && nvim
```

```powershell
# Windows (PowerShell)
git clone https://github.com/bcneal666/nvim.git $env:LOCALAPPDATA\nvim
nvim
```

首次啟動會自動 bootstrap lazy.nvim，並由 Mason 自動安裝 LSP / formatter / linter。

> **每台新機器 clone 後必做**：設定 `merge.autoStash` / `rebase.autoStash`（git config 不隨
> repo 走），步驟見 [CLAUDE.md](./CLAUDE.md#每台新機器的一次性設定必做)。

## 已啟用 Extras

| 分類 | Extra |
| --- | --- |
| AI | `ai.claudecode` |
| Editor | `editor.fzf` |
| Formatting | `formatting.prettier` |
| Lang | `lang.typescript`、`lang.tailwind`、`lang.json`、`lang.yaml`、`lang.markdown`、`lang.sql`、`lang.toml`、`lang.git`、`lang.solidity` |

新增語言支援優先用 `:LazyExtras`，不要手動設定 LSP。

## 自訂設定一覽（`lua/plugins/`）

| 檔案 | 插件 | 重點 |
| --- | --- | --- |
| `colorschema.lua` | cyberdream.nvim | 主題設為 cyberdream，`lazy=false priority=1000`，前景覆寫亮綠 |
| `blink.lua` | blink.cmp | `<CR>` 已選則 accept 否則換行；候選不預選 |
| `css.lua` | treesitter / cssls / tailwindcss / nvim-highlight-colors | Tailwind v4 `configFile` 指向 `app/globals.css`；`unknownAtRules` 設為忽略 |
| `typescript.lua` | vtsls | `maxTsServerMemory` 依 CPU 核數切換 1024／4096 MB |
| `snacks.lua` | snacks.explorer | 顯示隱藏檔；gitignore 命中仍隱藏；`.env*` 強制顯示 |
| `fzf.lua` | fzf-lua | files/grep 掃隱藏檔，排除 `.git`、`.jj` |
| `lint.lua` | nvim-lint | 修正 markdownlint-cli2 的 `cwd`（Windows 路徑非 `~/.config/nvim`） |
| `markdown.lua` | render-markdown.nvim | 停用（`enabled = false`） |

## 快捷鍵

| 按鍵 | 模式 | 作用 |
| --- | --- | --- |
| `jj` | insert | 離開 insert 模式 |
| `<CR>` | insert（補全中） | blink：已選候選則接受，否則換行 |
| `<C-Space>` | insert | blink：手動觸發補全 / 顯示文件 |
| `<leader>e` | normal | 開啟 snacks.explorer 檔案總管 |
| `H` / `I` | explorer 側欄 | 臨時切換 hidden / ignored 顯示 |

其餘沿用 LazyVim 預設快捷鍵。

## 常用指令

| 指令 | 用途 |
| --- | --- |
| `:Lazy` | 插件管理 UI |
| `:Lazy sync` | 同步至 lock 版本 |
| `:Lazy update` | 更新插件並寫入 `lazy-lock.json`（`checker` 已關閉，需手動執行） |
| `:Mason` | 管理 LSP / linter / formatter |
| `:LazyExtras` | 管理 extras（寫入 `lazyvim.json`） |
| `:checkhealth` | 診斷環境 |
| `:ConformInfo` | 查看目前 buffer 的 formatter |

## 格式化

- **Lua**：stylua（`stylua.toml`：2 空格縮排、120 字元寬度），存檔時由 conform.nvim 自動套用
- **JS/TS/CSS/JSON/Markdown**：prettier，僅在專案有 prettier 設定檔（`.prettierrc` 等）時才套用，避免污染沒用 prettier 的專案

## 目錄結構

```text
init.lua              # 入口點：require("config.lazy")
lazyvim.json          # LazyVim extras 清單
lazy-lock.json        # 插件版本鎖定（44 個）
stylua.toml           # Lua formatter 設定
.markdownlint.json    # markdownlint 設定
.gitattributes        # 換行統一為 LF
.gitignore            # 忽略暫存/除錯檔案
.neoconf.json         # neoconf/neodev：讓 lua_ls 認得 nvim API

lua/
  config/
    lazy.lua          # bootstrap + 全域設定（並發依核數、checker 關閉）
    options.lua       # vim.opt 覆寫、Windows 編譯器偵測、Linux OOM、SSH OSC 52 剪貼簿
    keymaps.lua       # 自訂快捷鍵（jj → <Esc>）
    autocmds.lua      # 停用 wrap_spell、關 vtsls semantic tokens
  plugins/
    colorschema.lua、blink.lua、css.lua、lint.lua、
    markdown.lua、typescript.lua、snacks.lua、fzf.lua
```

## 更多細節

跨機器同步（LF 換行、autoStash、lock 檔衝突處理）、OSC 52 剪貼簿實作原理、Linux 系統層依賴
完整清單、LSP 三層架構（Mason → mason-lspconfig → nvim-lspconfig）等，見 [CLAUDE.md](./CLAUDE.md)。

## License

[Apache License 2.0](./LICENSE)

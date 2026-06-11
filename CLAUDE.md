# CLAUDE.md

## 概覽

基於 **LazyVim** starter template 的 Neovim 配置。Lazy.nvim 管理 ~44 個插件。
主要特色：**blink.cmp popup + Codeium ghost text** 雙補全並存、**Cyberdream** 配色、Web 開發完整 LSP。

## 常用指令

| 指令 | 用途 |
| --- | --- |
| `:Lazy` | 插件管理 UI |
| `:Lazy sync` | 同步至 lock 版本 |
| `:Lazy update` | 更新插件並寫入 lazy-lock.json |
| `:Mason` | 管理 LSP / linter / formatter |
| `:LazyExtras` | 管理 extras（寫入 lazyvim.json） |
| `:checkhealth` | 診斷環境 |
| `:ConformInfo` | 查看目前 buffer 的 formatter |

Lua 格式化（直接執行）：`stylua lua/`（`stylua.toml`：2 空格縮排、120 字元寬度）
Mason 亦裝 `stylua` 供 conform.nvim 存檔時自動格式化，兩者共存。

## 目錄結構

```text
init.lua              # 入口點：require("config.lazy")
lazyvim.json          # LazyVim extras 清單
lazy-lock.json        # 插件版本鎖定
stylua.toml           # Lua formatter 設定
.markdownlint.json    # markdownlint 設定（MD013/MD060 已關）

lua/
  config/
    lazy.lua          # Lazy.nvim bootstrap + 全域設定
    options.lua       # vim.opt 覆寫（wrap、Windows 編譯器偵測）
    keymaps.lua       # 自訂快捷鍵（目前空白）
    autocmds.lua      # 自訂 autocmd（lazyvim_wrap_spell 已停用）
  plugins/
    colorschema.lua   # Cyberdream 主題（lazy:false, priority:1000）
    codeium.lua       # Codeium ghost text（含 Windows workaround）
    blink.lua         # blink.cmp 鍵位與 popup 行為（與 Codeium 並存）
    css.lua           # CSS/SCSS：Treesitter + cssls + highlight-colors
    lint.lua          # markdownlint-cli2 工作目錄設定
    markdown.lua      # 停用 render-markdown
    example.lua       # 範例 spec（已停用）
```

## 核心架構

### 載入流程

`init.lua` → `config/lazy.lua` → LazyVim 預設插件 → `lua/plugins/*.lua`

### 已啟用 LazyVim Extras（lazyvim.json）

- **AI**：`ai.claudecode`、`ai.codeium`
- **Editor**：`editor.fzf`（fzf-lua，取代 Telescope）
- **語言**：`lang.typescript`、`lang.python`、`lang.tailwind`、`lang.json`、`lang.yaml`、`lang.markdown`、`lang.sql`、`lang.toml`、`lang.git`、`lang.solidity`

新增語言支援優先用 `:LazyExtras`，不要手動設定 LSP。

### 補全策略

**blink.cmp**（LSP 補全 popup） + **Codeium ghost text**（行內建議）並存：

- `<Tab>` — Codeium：接受整個 ghost text 建議
- `<M-w>` — Codeium：接受一個單詞
- `<M-]>` / `<M-[>` — Codeium：下一個 / 上一個建議
- `<C-]>` — Codeium：取消建議
- `<CR>` — blink：已選則接受、沒選 fallback 換行
- `<C-Space>` — blink：手動觸發補全
- 輸入關鍵字時 blink popup 自動彈出（LSP 候選 / Tailwind class）

兩者視覺通常不衝突：blink popup 浮在游標下方、Codeium ghost text 嵌在游標後方。

### Windows 相容性

`options.lua` 自動偵測 GCC / Clang 作為 C 編譯器（Treesitter 用）。
`codeium.lua` 含 Windows 路徑大小寫與 CRLF 的 workaround。

## 插件慣例

1. 每個功能建獨立檔案於 `lua/plugins/`，回傳 Lazy.nvim spec table
2. 覆寫 LazyVim 預設插件時，**只指定要變更的欄位**（Lazy.nvim 會合併）
3. 停用插件：`enabled = false` 或 `return {}`

## LSP 設定

三層架構：**Mason**（安裝）→ **mason-lspconfig**（橋接）→ **nvim-lspconfig**（設定）

參考模式：`lua/plugins/css.lua`（同時設定三層）

## Linux 環境依賴

Clone 後先裝系統層工具（Mason 不處理這層）。

### 必裝

| 工具 | 套件名（Ubuntu/Debian） | 需要它的功能 |
| --- | --- | --- |
| `git` | `git` | lazy.nvim bootstrap、gitsigns |
| `gcc` / `clang` | `gcc` | nvim-treesitter 編譯 parser |
| `fzf` | `fzf` | editor.fzf（fzf-lua） |
| `ripgrep` | `ripgrep` | fzf 搜尋、grug-far |
| `fd` | `fd-find` | fzf 檔案搜尋 |
| `node` + `npm` | `nodejs npm` | TS/Tailwind/Solidity LSP、markdown-preview |
| `python3` + `pip` | `python3 python3-pip` | pyright、black、ruff、debugpy、yamllint |

```bash
sudo apt install git gcc fzf ripgrep fd-find nodejs npm python3 python3-pip
# Ubuntu：fd 執行檔叫 fdfind，需建 symlink
ln -sf $(which fdfind) ~/.local/bin/fd
```

### Mason 自動裝（進 nvim 後無需手動）

- **LSP**：tsserver、pyright、cssls、tailwindcss-language-server、yaml-language-server、taplo、jsonls、solidity-ls、codeium-language-server
- **Formatter**：prettier、black、stylua
- **Linter**：ruff、yamllint
- **DAP**：debugpy

### 選裝

| 工具 | 用途 |
| --- | --- |
| `psql` / `mysql` / `sqlite3` | lang.sql + vim-dadbod |
| `solc` | lang.solidity 編譯合約 |

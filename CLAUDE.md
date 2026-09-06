# CLAUDE.md

## 概覽

**LazyVim** starter 基底 Neovim 配置（Lazy.nvim 管 ~44 插件）。特色：**blink.cmp** 補全 popup、**Cyberdream** 配色、Web LSP 全套。

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

Lua 格式化：手動跑 `stylua lua/`，或存檔 conform.nvim 自動套（Mason 裝的 `stylua`，與系統版共存）。設定見 `stylua.toml`（2 空格縮排、120 字元寬）。
JS/TS/CSS/JSON/Markdown 交 prettier 處理（`formatting.prettier` extra），僅專案有 prettier 設定檔（`.prettierrc` 等）才格式化（`vim.g.lazyvim_prettier_needs_config = true`，見 `options.lua`），避免污染無 prettier 專案。

## 跨機器同步

此 repo 跨多機（Windows + Linux VPS）用 `git push` / `git pull` 同步。設定分兩種：隨 repo 走、各機自設，先分清楚：

| 項目 | 是否隨 repo 走 | 說明 |
| --- | --- | --- |
| `.gitattributes`（換行鎖 LF） | ✅ 在版控內 | clone 即生效，不需重設 |
| `merge.autoStash` / `rebase.autoStash` | ❌ 不在版控內 | 存於 `~/.gitconfig`，**每台機器要手動設一次** |

- **`lazy-lock.json` 是自動寫入檔**：`:Lazy update` 直接改寫它。裝完插件盡快 commit + push。兩機各 commit 同行不同版本＝真 merge conflict，autoStash 救不了，只能手動挑版本（通常取較新那次更新）。
- **換行統一為 LF**：`.gitattributes` 對全部追蹤檔設 `eol=lf`，避免 Windows（系統層 `core.autocrlf=true`）與 Linux 之間出現整檔換行的假 diff。勿改 `core.autocrlf`，`.gitattributes` 的 `eol` 優先權高於它。

### 剪貼簿（本機 vs SSH）

`options.lua` 靠 `SSH_TTY` / `SSH_CONNECTION` 判斷是否在 SSH session，僅遠端（如 VPS）設 `vim.g.clipboard` 走 OSC 52；本機不觸發，沿用 nvim 內建偵測（Wayland/X11 → `wl-copy` / `xclip`）。

- **paste 只讀 nvim 自身 register**，不用 OSC 52 query：`vim.ui.clipboard.osc52` 的 paste 需等終端機回應，逾時最長 10 秒，多數終端機剪貼簿讀取又需逐次授權，代價太高
- **yank 自動鏡射到 `+`**：`clipboard` 留空（不設 `unnamedplus`），改由 `TextYankPost` autocmd 只在 yank（非 `d`/`x`/`c`）且未指定 register 時寫進 `+`，觸發 OSC 52；`v` 選取後 `y` 即回本機，`"ay` 這類指定 register 的 yank 不鏡射
- **VPS 跑 tmux**：`~/.tmux.conf` 加 `set -g set-clipboard on`（tmux 2.6+，不進版控，各機自設），否則 OSC 52 序列被 tmux 攔截，轉不到終端機

### 每台新機器的一次性設定（必做）

git config 不在版控內，clone 後需自設：

```bash
# 1. 先確認 git 版本 ≥ 2.27（merge.autoStash 的最低要求）
git --version

# 2. pull 時自動暫存未提交變更，不必再 git reset --hard
git config --global merge.autoStash true
git config --global rebase.autoStash true

# 3. 驗證：兩行都應印出 true
git config --global --get merge.autoStash
git config --global --get rebase.autoStash
```

寫入位置：Linux 是 `~/.gitconfig`，Windows 是 `C:/Users/<使用者>/.gitconfig`。
只影響此 repo：`--global` 換 `--local`（需在 repo 目錄內執行）。

若 git < 2.27（舊版 Debian/Ubuntu 可能遇到），`merge.autoStash` 無效，改用 rebase 模式達成等效行為：

```bash
git config --global pull.rebase true    # 搭配 rebase.autoStash（1.8.4+ 即支援）
```

### 既有 checkout 的換行刷新（每台機器僅一次）

`.gitattributes` 加入後，舊工作區已 checkout 的 CRLF 檔不會自動轉換：

```bash
git status                              # 必須先確認乾淨，下一行會丟棄未提交變更
git rm --cached -r . && git reset --hard
git ls-files --eol                      # 每列應為 i/lf w/lf attr/text=auto eol=lf
```

Linux 本來就是 LF，這步主要影響 Windows 機器；新 clone 機器不用跑。

## 目錄結構

```text
init.lua              # 入口點：require("config.lazy")
lazyvim.json          # LazyVim extras 清單
lazy-lock.json        # 插件版本鎖定
stylua.toml           # Lua formatter 設定
.markdownlint.json    # markdownlint 設定（MD013/MD040/MD060 已關）
.gitattributes        # 換行鎖 LF（eol=lf）
.gitignore            # 忽略暫存/除錯檔案
.neoconf.json         # neoconf/neodev：讓 lua_ls 認得 nvim API

lua/
  config/
    lazy.lua          # bootstrap + 全域設定（並發依核數、checker 關）
    options.lua       # vim.opt 覆寫（wrap、shada 上限、Windows 編譯器偵測、Linux OOM）
    keymaps.lua       # 自訂快捷鍵（jj → <Esc>，離開 insert 模式）
    autocmds.lua      # 自訂 autocmd（停用 wrap_spell、關 vtsls semantic tokens）
  plugins/
    colorschema.lua   # Cyberdream 主題（lazy:false, priority:1000）
    blink.lua         # blink.cmp 鍵位與 popup 行為
    css.lua           # CSS/SCSS：Treesitter + cssls + highlight-colors
    lint.lua          # markdownlint-cli2 工作目錄設定
    markdown.lua      # 停用 render-markdown
    typescript.lua    # vtsls 設定（maxTsServerMemory 依機器）
    snacks.lua        # snacks explorer 過濾（顯示隱藏檔、強制顯示 .env）
    fzf.lua           # fzf-lua grep 掃隱藏檔
```

## 核心架構

### 載入流程

`init.lua` → `config/lazy.lua` → LazyVim 預設插件 → `lua/plugins/*.lua`

### 已啟用 LazyVim Extras（lazyvim.json）

- **AI**：`ai.claudecode`
- **Editor**：`editor.fzf`（fzf-lua，取代 Telescope）
- **語言**：`lang.typescript`、`lang.tailwind`、`lang.json`、`lang.yaml`、`lang.markdown`、`lang.sql`、`lang.toml`、`lang.git`、`lang.solidity`
- **Formatting**：`formatting.prettier`

新增語言支援：優先 `:LazyExtras`，勿手動設 LSP。

### 檔案總管

`<leader>e` 開 **snacks.explorer**（LazyVim v8 起預設，非 neo-tree；本 repo 未裝後者）。過濾規則見 `lua/plugins/snacks.lua`：優先權 `include` glob > `hidden` > `ignored`；現況點檔全開、gitignore 命中仍隱藏、`.env*` 用 `include` 強制顯示。側欄 `H` / `I` 臨時切換 hidden / ignored。

### 補全策略

單純 **blink.cmp** popup（LSP 候選 / Tailwind class），無行內 ghost text：

- `<CR>` — 已選則接受、未選 fallback 換行
- `<C-Space>` — 手動觸發補全
- `<Tab>` — snippet 待跳轉時跳下一個欄位，否則正常縮排
- 打關鍵字時 popup 自動彈出

> 原並存的 Codeium ghost text 已移除：Codeium 隨 Windsurf → Devin 改名棄用，`:Codeium Auth` 登入流程已失效。

### Windows 相容性

`options.lua` 自動偵測 GCC / Clang 當 C 編譯器（Treesitter 用）。

## 插件慣例

1. 每功能建獨立檔案於 `lua/plugins/`，回傳 Lazy.nvim spec table
2. 覆寫 LazyVim 預設插件：**只指定要改的欄位**（Lazy.nvim 會合併）
3. 停用插件：`enabled = false` 或 `return {}`

## LSP 設定

三層架構：**Mason**（安裝）→ **mason-lspconfig**（橋接）→ **nvim-lspconfig**（設定）

參考模式：`lua/plugins/css.lua`（同時設定三層）

## Linux 環境依賴

Clone 後先裝系統層工具（Mason 不管這層）。

### 必裝

| 工具 | 套件名（Ubuntu/Debian） | 需要它的功能 |
| --- | --- | --- |
| `git` | `git` | lazy.nvim bootstrap、gitsigns |
| `gcc` / `clang` | `gcc` | nvim-treesitter 編譯 parser |
| `fzf` | `fzf` | editor.fzf（fzf-lua） |
| `ripgrep` | `ripgrep` | fzf 搜尋、grug-far |
| `fd` | `fd-find` | fzf 檔案搜尋 |
| `node` + `npm` | `nodejs npm` | TS/Tailwind/Solidity LSP、markdown-preview、prettier |
| `python3` + `pip` | `python3 python3-pip` | 僅在啟用 `lang.python` extra 時需要（目前未啟用） |
| `wl-copy` / `wl-paste` | `wl-clipboard`（Wayland）或 `xclip`（X11） | 本機 `unnamedplus` 剪貼簿同步，缺了 `y` 貼不到系統剪貼簿 |

```bash
sudo apt install git gcc fzf ripgrep fd-find nodejs npm python3 python3-pip wl-clipboard
# Ubuntu：fd 執行檔叫 fdfind，需建 symlink
ln -sf $(which fdfind) ~/.local/bin/fd
```

X11 環境（無 Wayland）改裝 `xclip` 取代 `wl-clipboard`。

### Mason 自動裝（進 nvim 後無需手動）

- **LSP**：lua_ls、vtsls、cssls、tailwindcss-language-server、yaml-language-server、taplo、jsonls、solidity-ls、marksman
- **Formatter**：prettier、stylua、shfmt、markdown-toc
- **Linter**：markdownlint-cli2、sqlfluff

### 選裝

| 工具 | 用途 |
| --- | --- |
| `psql` / `mysql` / `sqlite3` | lang.sql + vim-dadbod |
| `solc` | lang.solidity 編譯合約 |

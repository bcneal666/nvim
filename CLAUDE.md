# CLAUDE.md

## Overview

**LazyVim** starter-based Neovim config (Lazy.nvim manages plugins). Features: **blink.cmp** popup completion, **Cyberdream** theme, full Web LSP stack.

## Commands

| Command | Purpose |
| --- | --- |
| `:Lazy` | Plugin manager UI |
| `:Lazy sync` | Install + clean + update (rewrites lazy-lock.json) |
| `:Lazy restore` | Restore lazy-lock.json versions |
| `:Lazy update` | Update plugins, write lazy-lock.json |
| `:Mason` | Manage LSP / linter / formatter |
| `:LazyExtras` | Manage extras (writes lazyvim.json) |
| `:checkhealth` | Diagnose environment |
| `:ConformInfo` | Show current buffer's formatter |

Lua format: run `stylua lua/` manually, or conform.nvim applies on save (Mason installs `stylua`; coexists with system one). Config: `stylua.toml` (2-space indent, 120 cols).
JS/TS/CSS/JSON/Markdown → prettier (`formatting.prettier` extra). Format only when project has prettier config file (`.prettierrc` etc.) (`vim.g.lazyvim_prettier_needs_config = true`, see `options.lua`) — avoids polluting projects without prettier.

## Cross-machine sync

Repo syncs across machines (Windows + Linux VPS) via `git push` / `git pull`. Two kinds of setup, keep distinct: travels with repo vs per-machine.

| Item | Travels with repo | Note |
| --- | --- | --- |
| `.gitattributes` (LF line endings) | Yes (versioned) | Effective on clone, no setup |
| `merge.autoStash` / `rebase.autoStash` | No (not versioned) | Lives in `~/.gitconfig`, **set once per machine manually** |

- **`lazy-lock.json` is auto-written**: `:Lazy update` rewrites it. Commit + push right after installing plugins. Two machines committing different versions on same line = real merge conflict; autoStash cannot fix; pick version manually (usually the newer update).
- **Line endings unified to LF**: `.gitattributes` sets `eol=lf` on all tracked files, avoiding whole-file fake diffs between Windows (system `core.autocrlf=true`) and Linux. Never change `core.autocrlf`; `.gitattributes` `eol` outranks it.

### Clipboard (local vs SSH)

`options.lua` detects SSH session via `SSH_TTY` / `SSH_CONNECTION`; only remote (e.g. VPS) sets `vim.g.clipboard` to OSC 52. Local: not triggered, uses nvim built-in detection (Wayland/X11 via `wl-copy` / `xclip`).

- **Paste reads only nvim's own register**, no OSC 52 query: `vim.ui.clipboard.osc52` paste waits up to 10 s for terminal response, and most terminals need per-read authorization — cost too high
- **Yank auto-mirrors to `+`**: `clipboard` left empty (no `unnamedplus`); `TextYankPost` autocmd writes `+` (triggers OSC 52) only on yank (not `d`/`x`/`c`) with no register specified; `v` select then `y` lands on local machine; yank with explicit register like `"ay` not mirrored
- **VPS running tmux**: add these two lines to `~/.tmux.conf` (tmux 2.6+, not versioned, per machine):

  ```tmux
  set -g set-clipboard on              # 預設值 external：tmux 自己能設剪貼簿，
                                        # 但會吞掉 pane 內應用程式（nvim）送出的 OSC 52
  set -ag terminal-features ',*:clipboard'   # 內建規則只認 xterm*，WezTerm/Alacritty/foot
                                              # 這些非 xterm* 的 TERM 需額外宣告才會轉發
  ```

  Apply to running server (editing config file does not affect an already started server):

  ```bash
  tmux set -g set-clipboard on
  tmux set -ag terminal-features ',*:clipboard'
  ```

  Never use `tmux kill-server` to apply — kills all existing sessions.

- **Local terminal must also support OSC 52 writes**, else none of above works: ghostty / kitty / WezTerm / Alacritty / Windows Terminal (recent) work by default; GNOME Terminal / Tilix / Terminator (VTE family) mostly unsupported — terminal limit, remote cannot fix. nvim-free one-line test (run inside and outside tmux; difference isolates tmux vs terminal):

  ```bash
  printf '\033]52;c;%s\a' "$(printf 'osc52-test' | base64)"
  ```

  Paste locally after running; seeing `osc52-test` = pass. Terminal unsupported → alternatives:
  - switch to supporting terminal (easiest)
  - Shift+mouse-drag inside tmux for terminal-native selection (also selects line numbers, signcolumn — disable them first)
  - run bidirectional clipboard relay like `lemonade` (one step more complex; also solves paste direction)

### One-time setup per new machine (required)

git config not versioned; set after clone:

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

Write location: Linux `~/.gitconfig`, Windows `C:/Users/<username>/.gitconfig`.
Affect this repo only: swap `--global` for `--local` (run inside repo dir).

git < 2.27 (old Debian/Ubuntu): `merge.autoStash` has no effect; use rebase mode for equivalent behavior:

```bash
git config --global pull.rebase true    # 搭配 rebase.autoStash（1.8.4+ 即支援）
```

### Line-ending refresh for existing checkouts (once per machine)

After `.gitattributes` was added, CRLF files already checked out are not auto-converted:

```bash
git status                              # 必須先確認乾淨，下一行會丟棄未提交變更
git rm --cached -r . && git reset --hard
git ls-files --eol                      # 每列應為 i/lf w/lf attr/text=auto eol=lf
```

Linux already LF; step mainly affects Windows machines; fresh clones skip.

## Directory structure

```text
init.lua              # 入口點：require("config.lazy")
lazyvim.json          # LazyVim extras 清單
lazy-lock.json        # 插件版本鎖定
stylua.toml           # Lua formatter 設定
.markdownlint.json    # markdownlint 設定（MD013/MD040/MD060 已關）
.gitattributes        # 換行鎖 LF（eol=lf）
.gitignore            # 忽略暫存/除錯檔案
.neoconf.json         # neoconf/neodev：讓 lua_ls 認得 nvim API
README.md             # 對外說明（安裝、設定、鍵位）
LICENSE               # Apache 2.0
skills-lock.json      # skills 來源與雜湊鎖定

.claude/
  settings.json       # Claude Code 專案設定（權限、SessionStart hook）
  skills/             # neovim、lazy-nvim-optimization（專案專用 skill）
.agents/skills/       # 同批 skill 的安裝器副本（含 caveman）

lua/
  config/
    lazy.lua          # bootstrap + 全域設定（並發依核數、checker 關）
    options.lua       # vim.opt 覆寫（wrap、shada 上限、Windows 編譯器偵測、Linux OOM、prettier 需設定檔、停用 sql omni 鍵位、SSH OSC 52 剪貼簿）
    keymaps.lua       # 自訂快捷鍵（jj → <Esc>，離開 insert 模式）
    autocmds.lua      # 自訂 autocmd（停用 wrap_spell、關 vtsls semantic tokens）
  plugins/
    colorschema.lua   # Cyberdream 主題（lazy:false, priority:1000）
    blink.lua         # blink.cmp 鍵位與 popup 行為
    css.lua           # CSS/SCSS：Treesitter + cssls + tailwindcss（v4 configFile → app/globals.css）+ highlight-colors
    lint.lua          # markdownlint-cli2 工作目錄設定
    markdown.lua      # 停用 render-markdown
    typescript.lua    # vtsls 設定（maxTsServerMemory 依機器）
    snacks.lua        # snacks explorer 過濾（顯示隱藏檔、強制顯示 .env）
    fzf.lua           # fzf-lua grep 掃隱藏檔
```

## Core architecture

### Load flow

`init.lua` → `config/lazy.lua` → LazyVim default plugins → `lua/plugins/*.lua`

### Enabled LazyVim extras (lazyvim.json)

- **AI**: `ai.claudecode`
- **Editor**: `editor.fzf` (fzf-lua, replaces Telescope)
- **Languages**: `lang.typescript`, `lang.tailwind`, `lang.json`, `lang.yaml`, `lang.markdown`, `lang.sql`, `lang.toml`, `lang.git`, `lang.solidity`
- **Formatting**: `formatting.prettier`

Add language support via `:LazyExtras` first (extras wire all three LSP layers); hand-write LSP config only when no extra fits, see LSP setup.

### File explorer

`<leader>e` opens **snacks.explorer** (LazyVim v8+ default, not neo-tree; neo-tree not installed). Filter rules in `lua/plugins/snacks.lua`: precedence `include` glob > `hidden` > `ignored`; currently dotfiles and gitignore hits (incl. `.git`, which snacks internally marks ignored) all shown; `.env*` additionally forced via `include` against future changes. Sidebar `H` / `I` temporarily toggle hidden / ignored.

### Completion

**blink.cmp** popup only (LSP candidates / Tailwind class); no inline ghost text:

- `<CR>` — accept if selected, else fall back to newline
- `<C-Space>` — trigger completion manually
- `<Tab>` — jump to next field when snippet pending, else normal indent
- Popup opens automatically while typing keywords

### Windows compatibility

`options.lua` auto-detects GCC / Clang as C compiler (for Treesitter).

## Plugin conventions

1. One file per feature in `lua/plugins/`, returning Lazy.nvim spec table
2. Overriding LazyVim default plugin: **specify only changed fields** (Lazy.nvim merges)
3. Disable plugin: `enabled = false` or `return {}`

## LSP setup

Three layers: **Mason** (install) → **mason-lspconfig** (bridge) → **nvim-lspconfig** (config)

Reference pattern: `lua/plugins/css.lua` configures Mason (`ensure_installed`) + nvim-lspconfig (`servers`). mason-lspconfig bridge needs no spec: LazyVim sets it up and auto-enables installed servers (`automatic_enable`).

## Linux dependencies

After clone, install system-level tools first (Mason does not manage this layer).

### Neovim itself: no apt

LazyVim `main` needs nvim ≥ 0.11.2. Ubuntu LTS apt `neovim` is frozen at release-time version (24.04: 0.9.5), never gets major upgrades; LazyVim errors immediately on it. Install official prebuilt tarball instead (x86_64; needs new-enough glibc; rerun same block to update):

```bash
sudo apt remove neovim neovim-runtime
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
sudo rm -rf /opt/nvim-linux-x86_64
sudo tar -C /opt -xzf nvim-linux-x86_64.tar.gz
sudo ln -sf /opt/nvim-linux-x86_64/bin/nvim /usr/local/bin/nvim
rm nvim-linux-x86_64.tar.gz
nvim --version | head -1                 # 應 ≥ 0.11.2
```

### Required

| Tool | Package (Ubuntu/Debian) | Needed by |
| --- | --- | --- |
| `git` | `git` | lazy.nvim bootstrap, gitsigns |
| `gcc` / `clang` | `gcc` | nvim-treesitter parser compile |
| `fzf` | `fzf` | editor.fzf (fzf-lua) |
| `ripgrep` | `ripgrep` | fzf search, grug-far |
| `fd` | `fd-find` | fzf file search |
| `node` + `npm` | `nodejs npm` | TS/Tailwind/Solidity LSP, markdown-preview, prettier |
| `python3` + `pip` | `python3 python3-pip` | Only if `lang.python` extra enabled (currently not) |
| `wl-copy` / `wl-paste` | `wl-clipboard` (Wayland) or `xclip` (X11) | Local `unnamedplus` clipboard sync; missing → `y` cannot reach system clipboard. **Pure-SSH VPS without GUI: skip** — OSC 52 uses terminal escape sequences, bypasses local X11/Wayland provider |

```bash
sudo apt install git gcc fzf ripgrep fd-find nodejs npm python3 python3-pip wl-clipboard
# Ubuntu：fd 執行檔叫 fdfind，需建 symlink
ln -sf $(which fdfind) ~/.local/bin/fd
```

X11 (no Wayland): install `xclip` instead of `wl-clipboard`.

### Old glibc: build tree-sitter-cli yourself

nvim-treesitter `main` compiles parsers via `tree-sitter build`. With no `tree-sitter` on PATH, LazyVim installs official prebuilt binary via Mason, needing glibc ≥ 2.39. Older systems (RHEL/Alma/Rocky 8, Debian 11/12, Ubuntu ≤ 22.04) hit `GLIBC_2.xx not found`; all parser installs fail. Check version: `ldd --version`.

```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --profile minimal
cargo install tree-sitter-cli --locked        # 約 3–4 分鐘，連結本機 glibc
rm -rf ~/.local/share/nvim/mason/packages/tree-sitter-cli ~/.local/share/nvim/mason/bin/tree-sitter
```

Mason `PATH = "prepend"`: broken Mason copy not removed shadows `~/.cargo/bin`. Then restart nvim or `:TSUpdate`. npm `tree-sitter-cli` also downloads prebuilt binary, useless here.

### Mason auto-installs (no manual step after entering nvim)

- **LSP**: lua_ls, vtsls, cssls, tailwindcss-language-server, yaml-language-server, taplo, jsonls, solidity-ls, marksman
- **Formatter**: prettier, stylua, shfmt, markdown-toc
- **Linter**: markdownlint-cli2, sqlfluff

### Optional

| Tool | Purpose |
| --- | --- |
| `psql` / `mysql` / `sqlite3` | lang.sql + vim-dadbod |
| `solc` | lang.solidity contract compile |
| `lazygit` | `<leader>gg` Git UI. Not in apt; fetch `lazygit_<ver>_Linux_x86_64.tar.gz` from [GitHub release](https://github.com/jesseduffield/lazygit/releases), extract `lazygit`, then `sudo install lazygit /usr/local/bin/` |

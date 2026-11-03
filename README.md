# 💤 Personal LazyVim Config

A LazyVim-based Neovim config with blink.cmp completion, the Cyberdream theme and a full web LSP stack.

Built on [LazyVim](https://github.com/LazyVim/LazyVim) and synced between Windows workstations and Linux VPS machines (`git push` / `git pull`).

## 📑 Contents

- [Quick start](#-quick-start)
- [Features](#-features)
- [Requirements](#-requirements)
- [Enabled extras](#-enabled-extras)
- [Plugin settings](#️-plugin-settings)
- [Keymaps](#️-keymaps)
- [Commands](#-commands)
- [Formatting](#-formatting)
- [Directory structure](#-directory-structure)
- [Skills](#-skills)
- [More details](#-more-details)
- [License](#-license)

## 🚀 Quick start

```bash
# Linux / macOS
git clone https://github.com/bcneal666/nvim.git ~/.config/nvim && nvim
```

```powershell
# Windows (PowerShell)
git clone https://github.com/bcneal666/nvim.git $env:LOCALAPPDATA\nvim
nvim
```

The first launch bootstraps lazy.nvim automatically, and Mason installs LSP servers, formatters and linters.

> [!IMPORTANT]
> On every new machine after cloning, set `merge.autoStash` / `rebase.autoStash` (git config does not travel with the repo). Steps are in [CLAUDE.md](./CLAUDE.md#one-time-setup-per-new-machine-required).

## ✨ Features

- **blink.cmp** handles the completion popup (LSP candidates, Tailwind classes)
- **Cyberdream** theme, foreground overridden to bright green `#00ff00`
- **fzf-lua** replaces Telescope, **snacks.explorer** replaces neo-tree
- **Core-count tuning** — one config fits VPS and workstation:
  - vtsls memory cap: ≤4 cores 1024 MB, more cores 4096 MB
  - lazy.nvim install concurrency: ≤4 cores 2, multi-core Linux capped at 8, Windows keeps the lazy.nvim default
- **Windows-friendly** — GCC/Clang auto-detection
- **SSH sessions** switch the clipboard to OSC 52 automatically, and yanks are mirrored back to the local `+` register; inside tmux you also need `set-clipboard on`, see [CLAUDE.md](./CLAUDE.md#clipboard-local-vs-ssh)

## 📦 Requirements

- Neovim ≥ 0.11.2 (LazyVim requirement; Ubuntu LTS apt packages are too old, see [CLAUDE.md](./CLAUDE.md#linux-dependencies) for the tarball install)
- `git`, and `gcc` or `clang` (Treesitter compiles parsers)
- `fzf`, `ripgrep`, `fd` (fzf-lua search)
- `node` + `npm` (TS/Tailwind/Solidity LSP, markdown-preview, prettier)
- `wl-clipboard` (Wayland) or `xclip` (X11): local clipboard provider; without it `y` cannot sync to the system clipboard
- Optional: `lazygit` (`<leader>gg`)

On Windows the tools above can be installed with `winget`; the full list of Linux system dependencies is in [CLAUDE.md](./CLAUDE.md#linux-dependencies).

## 🔌 Enabled extras

| Category | Extra |
| --- | --- |
| AI | `ai.claudecode` |
| Editor | `editor.fzf` |
| Formatting | `formatting.prettier` |
| Lang (web) | `lang.typescript`, `lang.tailwind`, `lang.json`, `lang.yaml`, `lang.toml` |
| Lang (other) | `lang.markdown`, `lang.sql`, `lang.git`, `lang.solidity` |

To add language support, use `:LazyExtras` first instead of configuring LSP by hand.

## ⚙️ Plugin settings

Custom specs live in `lua/plugins/`:

| File | Plugin | Highlights |
| --- | --- | --- |
| `colorschema.lua` | cyberdream.nvim | Theme with `lazy=false priority=1000`, green foreground |
| `blink.lua` | blink.cmp | `<CR>` accepts selection or inserts newline; no preselect |
| `css.lua` | treesitter / cssls / tailwindcss / highlight-colors | Tailwind v4 `configFile`, `unknownAtRules` ignored |
| `typescript.lua` | vtsls | `maxTsServerMemory` 1024 / 4096 MB by core count |
| `snacks.lua` | snacks.explorer | Shows hidden and gitignored files; `.env*` forced visible |
| `fzf.lua` | fzf-lua | files/grep scan hidden files, excluding `.git` and `.jj` |
| `lint.lua` | nvim-lint | Fixes markdownlint-cli2 `cwd` on Windows |
| `markdown.lua` | render-markdown.nvim | Disabled (`enabled = false`) |

- **css.lua** — Tailwind v4 `configFile` points to `app/globals.css`
- **snacks.lua** — gitignored files include `.git`; `.env*` is forced visible through `include`
- **lint.lua** — the Windows config path is not `~/.config/nvim`, so `cwd` uses `stdpath("config")`

## ⌨️ Keymaps

| Key | Mode | Action |
| --- | --- | --- |
| `jj` | insert | Leave insert mode |
| `<CR>` | insert (while completing) | blink: accept the selected item, otherwise newline |
| `<C-Space>` | insert | blink: trigger completion manually / show documentation |
| `<leader>e` | normal | Open the snacks.explorer file explorer |
| `H` / `I` | explorer sidebar | Temporarily toggle hidden / ignored files |

Everything else uses LazyVim's default keymaps.

## ⚡ Commands

| Command | Purpose |
| --- | --- |
| `:Lazy` | Plugin manager UI |
| `:Lazy sync` | Install + clean + update (rewrites `lazy-lock.json`) |
| `:Lazy restore` | Restore the versions in `lazy-lock.json` |
| `:Lazy update` | Update plugins and write `lazy-lock.json` |
| `:Mason` | Manage LSP / linter / formatter |
| `:LazyExtras` | Manage extras (writes `lazyvim.json`) |
| `:checkhealth` | Diagnose the environment |
| `:ConformInfo` | Show the current buffer's formatter |

`checker` is off, so run `:Lazy update` manually.

## 🎨 Formatting

- **Lua**: stylua (`stylua.toml`: 2-space indent, 120 columns), applied on save by conform.nvim
- **JS/TS/CSS/JSON/Markdown**: prettier, applied only when the project has a prettier config file (`.prettierrc` etc.), so projects that don't use prettier are left alone

## 📁 Directory structure

```text
init.lua              # entry point: require("config.lazy")
lazyvim.json          # LazyVim extras list
lazy-lock.json        # plugin version lock
stylua.toml           # Lua formatter config
.markdownlint.json    # markdownlint config
.gitattributes        # line endings unified to LF
.gitignore            # ignores temp/debug files
.neoconf.json         # neoconf/neodev: lets lua_ls know the nvim API
README.md             # this file
LICENSE               # Apache 2.0
skills-lock.json      # skill sources and hashes

.claude/
  settings.json       # Claude Code project settings (permissions, SessionStart hook)
  skills/             # neovim, lazy-nvim-optimization
.agents/skills/       # installer copy of the same skills (plus caveman)

lua/
  config/
    lazy.lua          # bootstrap + global settings (concurrency by core count, checker off)
    options.lua       # vim.opt overrides, Windows compiler detection, Linux OOM, SSH OSC 52 clipboard, prettier needs config, sql omni maps off
    keymaps.lua       # custom keymaps (jj → <Esc>)
    autocmds.lua      # disables wrap_spell, turns off vtsls semantic tokens
  plugins/
    colorschema.lua, blink.lua, css.lua, lint.lua,
    markdown.lua, typescript.lua, snacks.lua, fzf.lua
```

## 🧩 Skills

Project skills for Claude Code live in `.claude/skills/`:

- `neovim` — guide to this config: plugins, keybindings, LSP, debugging
- `lazy-nvim-optimization` — startup profiling and lazy-loading specs

`.agents/skills/` holds the installer's copy and `skills-lock.json` pins source and hash of each skill.

## 📝 More details

[CLAUDE.md](./CLAUDE.md) covers:

- cross-machine sync (LF line endings, autoStash, lock-file conflicts)
- how the OSC 52 clipboard works
- the full list of Linux system dependencies
- the three-layer LSP architecture (Mason → mason-lspconfig → nvim-lspconfig)

## 📄 License

[Apache License 2.0](./LICENSE)

# 💤 Personal LazyVim Config

A Neovim config based on [LazyVim](https://github.com/LazyVim/LazyVim): blink.cmp popup completion,
Cyberdream theme, and a full LSP stack for web development. Synced between Windows workstations and
Linux VPS machines (`git push` / `git pull`).

## Features

- **blink.cmp** handles the completion popup (LSP candidates, Tailwind classes)
- **Cyberdream** theme, foreground overridden to bright green `#00ff00`
- **fzf-lua** replaces Telescope, **snacks.explorer** replaces neo-tree
- Tunes itself to CPU core count: vtsls memory cap (≤4 cores 1024 MB / more cores 4096 MB) and lazy.nvim
  install concurrency (≤4 cores: 2; multi-core Linux: capped at 8; Windows keeps the lazy.nvim default),
  so one config works on both VPS and workstation
- **Windows-friendly**: GCC/Clang auto-detection
- **SSH sessions** switch the clipboard to OSC 52 automatically, and yanks are mirrored back to the local
  `+` register; inside tmux you also need `set-clipboard on`, see
  [CLAUDE.md](./CLAUDE.md#clipboard-local-vs-ssh)

## Requirements

- Neovim ≥ 0.11.2 (LazyVim requirement; Ubuntu LTS apt packages are too old, see
  [CLAUDE.md](./CLAUDE.md#linux-dependencies) for the tarball install)
- `git`, and `gcc` or `clang` (Treesitter compiles parsers)
- `fzf`, `ripgrep`, `fd` (fzf-lua search)
- `node` + `npm` (TS/Tailwind/Solidity LSP, markdown-preview, prettier)
- `wl-clipboard` (Wayland) or `xclip` (X11): local clipboard provider; without it `y` cannot sync to the
  system clipboard
- Optional: `lazygit` (`<leader>gg`)

On Windows the tools above can be installed with `winget`; the full list of Linux system dependencies is in
[CLAUDE.md](./CLAUDE.md#linux-dependencies).

## Installation

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

> **Required on every new machine after cloning**: set `merge.autoStash` / `rebase.autoStash` (git config
> does not travel with the repo). Steps are in
> [CLAUDE.md](./CLAUDE.md#one-time-setup-per-new-machine-required).

## Enabled extras

| Category | Extra |
| --- | --- |
| AI | `ai.claudecode` |
| Editor | `editor.fzf` |
| Formatting | `formatting.prettier` |
| Lang | `lang.typescript`, `lang.tailwind`, `lang.json`, `lang.yaml`, `lang.markdown`, `lang.sql`, `lang.toml`, `lang.git`, `lang.solidity` |

To add language support, use `:LazyExtras` first instead of configuring LSP by hand.

## Custom settings (`lua/plugins/`)

| File | Plugin | Highlights |
| --- | --- | --- |
| `colorschema.lua` | cyberdream.nvim | Sets the cyberdream theme, `lazy=false priority=1000`, bright green foreground override |
| `blink.lua` | blink.cmp | `<CR>` accepts the selected item, otherwise inserts a newline; no preselected candidate |
| `css.lua` | treesitter / cssls / tailwindcss / nvim-highlight-colors | Tailwind v4 `configFile` points to `app/globals.css`; `unknownAtRules` ignored |
| `typescript.lua` | vtsls | `maxTsServerMemory` switches between 1024 / 4096 MB by CPU core count |
| `snacks.lua` | snacks.explorer | Shows hidden files; gitignored files (including `.git`) also shown; `.env*` forced visible via include |
| `fzf.lua` | fzf-lua | files/grep scan hidden files, excluding `.git` and `.jj` |
| `lint.lua` | nvim-lint | Fixes markdownlint-cli2 `cwd` (Windows path is not `~/.config/nvim`) |
| `markdown.lua` | render-markdown.nvim | Disabled (`enabled = false`) |

## Keymaps

| Key | Mode | Action |
| --- | --- | --- |
| `jj` | insert | Leave insert mode |
| `<CR>` | insert (while completing) | blink: accept the selected item, otherwise newline |
| `<C-Space>` | insert | blink: trigger completion manually / show documentation |
| `<leader>e` | normal | Open the snacks.explorer file explorer |
| `H` / `I` | explorer sidebar | Temporarily toggle hidden / ignored files |

Everything else uses LazyVim's default keymaps.

## Commands

| Command | Purpose |
| --- | --- |
| `:Lazy` | Plugin manager UI |
| `:Lazy sync` | Install + clean + update (rewrites `lazy-lock.json`) |
| `:Lazy restore` | Restore the versions in `lazy-lock.json` |
| `:Lazy update` | Update plugins and write `lazy-lock.json` (`checker` is off, so run it manually) |
| `:Mason` | Manage LSP / linter / formatter |
| `:LazyExtras` | Manage extras (writes `lazyvim.json`) |
| `:checkhealth` | Diagnose the environment |
| `:ConformInfo` | Show the current buffer's formatter |

## Formatting

- **Lua**: stylua (`stylua.toml`: 2-space indent, 120 columns), applied on save by conform.nvim
- **JS/TS/CSS/JSON/Markdown**: prettier, applied only when the project has a prettier config file
  (`.prettierrc` etc.), so projects that don't use prettier are left alone

## Directory structure

```text
init.lua              # entry point: require("config.lazy")
lazyvim.json          # LazyVim extras list
lazy-lock.json        # plugin version lock
stylua.toml           # Lua formatter config
.markdownlint.json    # markdownlint config
.gitattributes        # line endings unified to LF
.gitignore            # ignores temp/debug files
.neoconf.json         # neoconf/neodev: lets lua_ls know the nvim API

lua/
  config/
    lazy.lua          # bootstrap + global settings (concurrency by core count, checker off)
    options.lua       # vim.opt overrides, Windows compiler detection, Linux OOM, SSH OSC 52 clipboard
    keymaps.lua       # custom keymaps (jj → <Esc>)
    autocmds.lua      # disables wrap_spell, turns off vtsls semantic tokens
  plugins/
    colorschema.lua, blink.lua, css.lua, lint.lua,
    markdown.lua, typescript.lua, snacks.lua, fzf.lua
```

## More details

Cross-machine sync (LF line endings, autoStash, lock-file conflicts), how the OSC 52 clipboard works, the
full list of Linux system dependencies, and the three-layer LSP architecture (Mason → mason-lspconfig →
nvim-lspconfig) are covered in [CLAUDE.md](./CLAUDE.md).

## License

[Apache License 2.0](./LICENSE)

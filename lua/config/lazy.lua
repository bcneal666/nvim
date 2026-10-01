local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- 並發數依 CPU 核數自動調整：
--   少核（VPS 2 核）壓到 2，避免 git/網路/記憶體爭搶。
--   多核 Windows 工作站設 nil，交還 lazy.nvim 預設（nproc*2）→ install/update/sync 全速。
--   多核 Linux 壓到 8：預設在 Linux 不設上限，數十個 git clone 同時寫檔會塞爆
--   ClamAV on-access 掃描（OnAccessPrevention），拖過 git timeout 導致 install failed。
local nproc = (vim.uv or vim.loop).available_parallelism and (vim.uv or vim.loop).available_parallelism() or 8
local multicore_concurrency = 8
if vim.fn.has("win32") == 1 then
  multicore_concurrency = nil
end

require("lazy").setup({
  concurrency = nproc <= 4 and 2 or multicore_concurrency,
  git = {
    timeout = 240, -- 預設 120s，VPS 網速慢時易誤判卡死（此為上限非延遲，多核快網機無害）
  },
  spec = {
    -- add LazyVim and import its plugins
    { "LazyVim/LazyVim", import = "lazyvim.plugins" },
    -- import/override with your plugins
    { import = "plugins" },
  },
  defaults = {
    -- By default, only LazyVim plugins will be lazy-loaded. Your custom plugins will load during startup.
    -- If you know what you're doing, you can set this to `true` to have all your custom plugins lazy-loaded by default.
    lazy = false,
    -- It's recommended to leave version=false for now, since a lot the plugin that support versioning,
    -- have outdated releases, which may break your Neovim install.
    version = false, -- always use the latest git commit
    -- version = "*", -- try installing the latest stable version for plugins that support semver
  },
  install = { colorscheme = { "tokyonight", "habamax" } },
  checker = {
    -- 關閉週期性背景更新檢查：每次檢查會對 44 個插件 git fetch（VPS 慢網吃力、
    -- 且 Defender 會掃這些 git I/O）。改用手動 :Lazy update，行為更可預期。
    enabled = false,
    notify = false,
  },
  performance = {
    rtp = {
      -- disable some rtp plugins
      disabled_plugins = {
        "gzip",
        -- "matchit",
        -- "matchparen",
        -- "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})

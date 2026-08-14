return {
  "ibhagwan/fzf-lua",
  opts = {
    files = { hidden = true }, -- 已是 fzf-lua 預設，明寫防未來上游改動
    grep = {
      hidden = true,
      -- 加 --hidden 後 rg 會掃進 .git/，必須自己排除；
      -- 這串是 fzf-lua 預設值 + 兩個 glob，尾端 -e 不可刪
      rg_opts = "--column --line-number --no-heading --color=always --smart-case "
        .. '--max-columns=4096 -g "!.git" -g "!.jj" -e',
    },
  },
}

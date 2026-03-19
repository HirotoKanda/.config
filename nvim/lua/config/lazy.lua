-- lazy.nvimの設定
-- Ref: https://lazy.folke.io/installation

-- lazy.nvim install
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Setup lazy.nvim
require("lazy").setup({
  spec = {
    -- lua/plugins/ 以下のluaファイルをlazy.nvimのPlugin Specとして自動で読み込む
    { import = "plugins" },
  },
})

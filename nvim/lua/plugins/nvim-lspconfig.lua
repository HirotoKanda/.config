---@type LazyPluginSpec
return {
  "neovim/nvim-lspconfig",
  -- Bufferが読み込まれるときをトリガーに遅延ロードする
  event = { "BufReadPre", "BufNewFile" },
}

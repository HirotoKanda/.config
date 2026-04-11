local runtime = vim.env.VIMRUNTIME or vim.fn.expand "$VIMRUNTIME"

local library = {
  runtime,
  runtime .. "/lua",
  vim.fn.stdpath("config") .. "/lua",
}

return {
  cmd = { "lua-language-server" },
  filetypes = { "lua" },
  settings = {
    Lua = {
      diagnostics = {
        unusedLocalExclude = { "_*" },
      },
      telemetry = {
        enable = false,
      },
      workspace = {
        checkThirdParty = false,
        library = library,
      },
    },
  },
}

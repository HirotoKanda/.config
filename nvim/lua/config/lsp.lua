local M = {}

M.servers = {
  "astro",
  "clangd",
  "fortls",
  "intelephense",
  "lua_ls",
  "pyright",
  "tailwindcss",
  "texlab",
  "volar",
  "vtsls",
}

M.ensure_installed = vim.deepcopy(M.servers)

function M.on_attach(client, bufnr)
  if not client:supports_method("textDocument/completion", bufnr) then return end

  local completion = client.server_capabilities.completionProvider
  if completion then
    local chars = {}
    for i = 32, 126 do
      chars[#chars + 1] = string.char(i)
    end
    completion.triggerCharacters = chars
  end

  vim.lsp.completion.enable(true, client.id, bufnr, { autotrigger = true })
end

return M

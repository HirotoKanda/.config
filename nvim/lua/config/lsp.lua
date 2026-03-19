--loads settings from lspconfig
require("mason").setup()
require("mason-lspconfig").setup({
	ensure_installed = {
		"astro",
		"intelephense",
		"lua_ls",
		"tailwindcss",
		"volar",
		"vtsls",
	},
})


vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("my.lsp", {}),
  callback = function(args)
    local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
    -- 補完の設定
    if client:supports_method('textDocument/completion') then
      -- 文字を入力する度に補完を表示（遅くなる可能性あり）
      local chars = {}; for i = 32, 126 do table.insert(chars, string.char(i)) end
      client.server_capabilities.completionProvider.triggerCharacters = chars
      -- 補完を有効化
      vim.lsp.completion.enable(true, client.id, args.buf, {autotrigger = true})
    end
    -- フォーマット
    if not client:supports_method('textDocument/willSaveWaitUntil')
      and client:supports_method('textDocument/formatting') then
      vim.api.nvim_create_autocmd('BufWritePre', {
        group = vim.api.nvim_create_augroup('my.lsp', {clear=false}),
        buffer = args.buf,
        callback = function()
          vim.lsp.buf.format({bufnr = args.buf, id = client.id, timeout_ms = 3000})
        end,
      })
    end
  end,
})

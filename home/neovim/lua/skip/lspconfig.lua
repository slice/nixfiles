local lsp = require('skip.lsp')
local nls = require('null-ls')
local lspconfig = require('lspconfig')

vim.diagnostic.config({
  virtual_text = true,
  -- make warnings and errors appear over hints
  severity_sort = true,
})

lspconfig.tsserver.setup({
  capabilities = lsp.capabilities,
  on_attach = function(client, bufnr)
    lsp.on_shared_attach(client, bufnr)
    client.server_capabilities.documentFormattingProvider = false
    client.server_capabilities.documentRangeFormattingProvider = false
  end,
})

lspconfig.sourcekit.setup({})

lspconfig.pyright.setup({
  capabilities = lsp.capabilities,
  on_attach = lsp.on_shared_attach,
})

-- now handled by rust-tools.nvim (see plugins.lua)
--
-- lspconfig.rust_analyzer.setup({
--   capabilities = lsp.capabilities,
--   on_attach = lsp.on_shared_attach,
--   settings = {
--     ['rust-analyzer'] = {
--       imports = {
--         granularity = {
--           group = 'module',
--         },
--         prefix = 'crate',
--       },
--       procMacro = {
--         enable = true,
--       },
--     },
--   },
-- })

nls.setup({
  sources = {
    nls.builtins.formatting.prettier,
    nls.builtins.formatting.nixfmt,
    nls.builtins.diagnostics.shellcheck,
    nls.builtins.formatting.stylua,
    nls.builtins.formatting.black,
    nls.builtins.diagnostics.stylelint,
  },
  capabilities = lsp.capabilities,
  on_attach = lsp.on_shared_attach,
  should_attach = function(bufnr)
    return not lsp.bufname_banned(vim.api.nvim_buf_get_name(bufnr))
  end,
})

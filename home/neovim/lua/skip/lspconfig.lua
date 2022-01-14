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
    client.resolved_capabilities.document_formatting = false
    client.resolved_capabilities.document_range_formatting = false
  end,
})

lspconfig.hls.setup({
  capabilities = lsp.capabilities,
  on_attach = lsp.on_shared_attach,
})

lspconfig.rust_analyzer.setup({
  capabilities = lsp.capabilities,
  on_attach = lsp.on_shared_attach,
  settings = {
    ['rust-analyzer'] = {
      assist = {
        importMergeBehavior = 'last',
        importPrefix = 'by_self',
      },
      cargo = {
        loadOutDirsFromCheck = true,
      },
      procMacro = {
        enable = true,
      },
    },
  },
})

nls.setup({
  sources = {
    nls.builtins.formatting.prettier,
    nls.builtins.formatting.nixfmt,
    nls.builtins.diagnostics.shellcheck,
    nls.builtins.formatting.stylua,
    nls.builtins.diagnostics.stylelint,
  },
  capabilities = lsp.capabilities,
  on_attach = lsp.on_shared_attach,
})

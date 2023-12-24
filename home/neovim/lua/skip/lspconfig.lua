local lsp = require('skip.lsp')
local nls = require('null-ls')
local lspconfig = require('lspconfig')

vim.diagnostic.config({
  -- make warnings and errors appear over hints
  severity_sort = true,
  float = {
    header = '',
  },
})

lspconfig.sourcekit.setup({})

lspconfig.lua_ls.setup({})

lspconfig.pyright.setup({
  capabilities = lsp.capabilities,
})

lspconfig.hls.setup({
  filetypes = { 'haskell', 'lhaskell', 'cabal' },
})

lspconfig.rust_analyzer.setup({
  capabilities = lsp.capabilities,
  settings = {
    ['rust-analyzer'] = {
      imports = {
        granularity = {
          group = 'module',
        },
        prefix = 'crate',
      },
      procMacro = {
        enable = true,
      },
    },
  },
})

nls.setup({
  sources = {
    -- nls.builtins.formatting.prettier,
    -- ahggggghhhhhh
    nls.builtins.diagnostics.shellcheck,
    nls.builtins.diagnostics.stylelint,
    nls.builtins.diagnostics.eslint_d,
    nls.builtins.code_actions.eslint_d,
  },
  capabilities = lsp.capabilities,
  should_attach = function(bufnr)
    return lsp.attach_allowed(vim.api.nvim_buf_get_name(bufnr))
  end,
})

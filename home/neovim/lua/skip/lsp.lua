local M = {}

function map_buf(mode, key, result)
  vim.keymap.set(mode, key, result, { buffer = true, remap = false, silent = true })
end

-- setup a buffer with an lsp server attached with the proper mappings and
-- options
function M.setup_lsp_buf(client, bufnr)
  if client.server_capabilities.documentFormattingProvider then
    vim.cmd([[autocmd BufWritePre <buffer> lua vim.lsp.buf.format()]])
  end

  if client.server_capabilities.codeLensProvider then
    vim.cmd([[autocmd BufEnter,CursorHold,InsertLeave <buffer> lua vim.lsp.codelens.refresh()]])
  end

  vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
  vim.api.nvim_buf_set_option(bufnr, 'formatexpr', 'v:lua.vim.lsp.formatexpr()')

  map_buf('n', '<c-]>', vim.lsp.buf.definition)
  map_buf('n', 'K', vim.lsp.buf.hover)
  map_buf('n', '<leader>la', vim.lsp.buf.code_action)
  map_buf('n', '<leader>lr', vim.lsp.buf.rename)
  map_buf('n', '<leader>lf', vim.lsp.buf.format)
  map_buf('n', '<leader>lz', vim.lsp.codelens.run)
  vim.cmd(
    [[autocmd CursorHold <buffer> lua vim.diagnostic.open_float(nil, { scope = "line", source = "if_many", focusable = false, focus = false })]]
  )
end

M.banned_patterns = { '^/nix/store/', '%.cargo/registry', 'node_modules/' }

-- we patch lspconfig.util.bufname_valid to call this
function M.bufname_banned(bufname)
  for _, banned_pattern in ipairs(M.banned_patterns) do
    if bufname:find(banned_pattern) then
      -- vim.api.nvim_echo({ { string.format('(>_>)o not attaching LSP; matched %s', banned_pattern) } }, true, {})
      return true
    end
  end
  return false
end

-- this function should be passed to `on_attach` when setting up all language
-- servers!
function M.on_shared_attach(client, bufnr)
  vim.api.nvim_echo(
    { { string.format('(>_>)o LSP %s (ID: %s) attached to bufnr: %d', client.name, client.id, bufnr) } },
    true,
    {}
  )

  M.setup_lsp_buf(client, bufnr)
  if vim.api.nvim_buf_get_option(0, 'filetype') == 'rust' then
    vim.cmd(
      [[autocmd BufEnter,BufWritePost <buffer> ]]
        .. [[:lua require('lsp_extensions.inlay_hints').request ]]
        .. [[{ prefix = ' :: ', enabled = {'ChainingHint', 'TypeHint', 'ParameterHint'}}]]
    )
  end
end

M.capabilities = require('cmp_nvim_lsp').default_capabilities()

return M

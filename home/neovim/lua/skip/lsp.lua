local M = {}

function map_buf(mode, key, result)
  vim.api.nvim_buf_set_keymap(0, mode, key, result, { noremap = true, silent = true })
end

-- setup a buffer with an lsp server attached with the proper mappings and
-- options
function M.setup_lsp_buf(client, bufnr)
  if client.resolved_capabilities.document_formatting then
    vim.cmd([[autocmd BufWritePre <buffer> lua vim.lsp.buf.formatting_sync(nil, 2000)]])
  end

  vim.api.nvim_buf_set_option(0, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
  vim.api.nvim_buf_set_option(0, 'formatexpr', 'v:lua.vim.lsp.formatexpr()')

  map_buf('n', '<c-]>', '<cmd>lua vim.lsp.buf.definition()<CR>')
  map_buf('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>')
  map_buf('n', '<leader>la', '<cmd>lua vim.lsp.buf.code_action()<CR>')
  map_buf('n', '<leader>lr', '<cmd>lua vim.lsp.buf.rename()<CR>')
  map_buf('n', '<leader>lf', '<cmd>lua vim.lsp.buf.formatting_sync(nil, 2000)<CR>')
  vim.cmd(
    [[autocmd CursorHold <buffer> lua vim.diagnostic.open_float(nil, { scope = "line", source = "if_many", focusable = false, focus = false })]]
  )
end

-- this function should be passed to `on_attach` when setting up all language
-- servers!
function M.on_shared_attach(client, bufnr)
  vim.cmd(string.format('echomsg "(>_>)o attach for: %s (%s), bufnr: %d"', client.name, client.id, bufnr))

  M.setup_lsp_buf(client, bufnr)
  if vim.api.nvim_buf_get_option(0, 'filetype') == 'rust' then
    vim.cmd(
      [[autocmd BufEnter,BufWritePost <buffer> ]]
        .. [[:lua require('lsp_extensions.inlay_hints').request ]]
        .. [[{ prefix = ' :: ', enabled = {'ChainingHint', 'TypeHint', 'ParameterHint'}}]]
    )
  end
end

M.capabilities = vim.lsp.protocol.make_client_capabilities()
M.capabilities = require('cmp_nvim_lsp').update_capabilities(M.capabilities)

return M

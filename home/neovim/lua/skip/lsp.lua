local M = {}

function map_buf(mode, key, result)
  vim.keymap.set(mode, key, result, { buffer = true, remap = false, silent = true })
end

-- a set of flags that make it easy to toggle certain behaviors on the fly in
-- special circumstances
M.noattach_key = 'LSP_NOATTACH'
M.noformat_key = 'LSP_NOFORMAT'

function flag_set(name)
  return vim.g[name] == 1 or vim.b[name] == 1 or vim.t[name] == 1 or vim.w[name] == 1
end

M.formatting_augroup = vim.api.nvim_create_augroup('LspAutomaticFormatting', {})

-- setup a buffer with an lsp server attached with the proper mappings and
-- options
function M.setup_lsp_buf(client, bufnr)
  if client.server_capabilities.documentFormattingProvider then
    vim.api.nvim_create_autocmd({ 'BufWritePre' }, {
      desc = 'LSP-powered automatic formatting on buffer write',
      group = M.formatting_augroup,
      buffer = 0,
      callback = function(info)
        if flag_set(M.noformat_key) then
          return
        end

        vim.lsp.buf.format()
      end,
    })
  end

  if client.server_capabilities.codeLensProvider then
    vim.cmd([[autocmd BufEnter,CursorHold,InsertLeave <buffer> lua vim.lsp.codelens.refresh()]])
  end

  vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
  -- vim.lsp.inlay_hint(0, true) -- :O)

  map_buf('n', '<c-]>', vim.lsp.buf.definition)
  map_buf('n', 'K', vim.lsp.buf.hover)
  map_buf('n', '<leader>la', vim.lsp.buf.code_action)
  map_buf('n', '<leader>lr', vim.lsp.buf.rename)
  map_buf('n', '<leader>lf', function()
    vim.lsp.buf.format({ timeout_ms = 1000 * 4 })
  end)
  map_buf('n', '<leader>lz', vim.lsp.codelens.run)
  vim.cmd(
    [[autocmd CursorHold <buffer> lua vim.diagnostic.open_float(nil, { scope = "line", source = "if_many", focusable = false, focus = false })]]
  )
end

M.banned_patterns = { '^/nix/store/', '%.cargo/registry', 'node_modules/' }

-- we patch lspconfig.util.bufname_valid to call this
function M.attach_allowed(bufname)
  -- i'd add some cute messages here, but this function can be called more than
  -- once and i don't want to trigger the hit-enter-prompt

  if flag_set(M.noattach_key) then
    return false
  end

  for _, banned_pattern in ipairs(M.banned_patterns) do
    if bufname:find(banned_pattern) then
      return false
    end
  end

  return true
end

-- this function should be passed to `on_attach` when setting up all language
-- servers!
function M.on_shared_attach(client, bufnr)
  vim.api.nvim_echo(
    { { string.format('(^_^)/ LSP %s (ID: %s) attached to bufnr %d', client.name, client.id, bufnr) } },
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

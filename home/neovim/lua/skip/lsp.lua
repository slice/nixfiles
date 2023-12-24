local utils = require('skip.utils')

local M = {}

local function map_buf(mode, key, result, opts)
  vim.keymap.set(
    mode,
    key,
    result,
    vim.tbl_extend('force', { buffer = true, remap = false, silent = true }, opts or {})
  )
end

-- a set of flags that make it easy to toggle certain behaviors on the fly in
-- special circumstances
M.noattach_key = 'LSP_NOATTACH'
M.noformat_key = 'LSP_NOFORMAT'

local function flag_set(name)
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
      buffer = bufnr,
      callback = function(args)
        if flag_set(M.noformat_key) then
          return
        end

        require('conform').format({
          bufnr = bufnr,
          lsp_fallback = true,
        })
      end,
    })
  end

  if client.server_capabilities.codeLensProvider then
    vim.cmd([[autocmd BufEnter,CursorHold,InsertLeave <buffer> lua vim.lsp.codelens.refresh()]])
  end

  vim.bo.omnifunc = 'v:lua.vim.lsp.omnifunc'

  map_buf('n', '<c-]>', vim.lsp.buf.definition)
  map_buf('n', 'K', vim.lsp.buf.hover)
  map_buf('n', '<leader>la', vim.lsp.buf.code_action, { desc = 'Code actions' })
  map_buf('n', '<leader>lr', vim.lsp.buf.rename, { desc = 'Rename symbol' })
  map_buf('n', '<leader>li', function()
    local is_enabled = vim.lsp.inlay_hint.is_enabled(0)
    vim.lsp.inlay_hint.enable(0, not is_enabled)
  end, { desc = 'Toggle inlay hints' })
  map_buf('n', '<leader>lf', function()
    require('conform').format({ timeout_ms = 3000, lsp_fallback = true })
  end, { desc = 'Format buffer' })
  map_buf('n', '<leader>lz', vim.lsp.codelens.run, { desc = 'Run codelens' })
  vim.cmd(
    [[autocmd CursorHold <buffer> lua vim.diagnostic.open_float(nil, { scope = "line", source = "if_many", focusable = false, focus = false })]]
  )
end

M.banned_patterns = {
  '^/nix/store/',
  '%.cargo/registry',
  -- 'node_modules/'
  -- let this through for now, i wanna navigate between symbols in *.d.ts files
  -- TODO: make something more elaborate, because LSP is probably OK in library
  -- files but not null-ls (or equiv.)
}

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

utils.autocmds('SkipLsp', {
  {
    'LspAttach',
    {
      pattern = '*',
      callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if not client then
          return
        end
        local bufnr = args.buf

        M.setup_lsp_buf(client, bufnr)

        vim.schedule(function()
          vim.api.nvim_echo(
            { { string.format('(^_^)/ LSP server "%s" (%d) attached to bufnr %d', client.name, client.id, bufnr) } },
            true,
            {}
          )
        end)
      end,
      desc = 'Sets up autocmds and mappings for buffers that use LSP',
    },
  },
})

M.capabilities = require('cmp_nvim_lsp').default_capabilities()

return M

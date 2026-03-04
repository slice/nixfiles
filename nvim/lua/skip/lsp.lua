-- vim: set fdm=marker:
local utils = require('skip.utils')

local M = {}

M.noattach_key = 'LSP_NOATTACH'
M.noformat_key = 'LSP_NOFORMAT'

M.buf_lsp_augroup = vim.api.nvim_create_augroup('SkipBufferLsp', {})
M.formatting_augroup =
  vim.api.nvim_create_augroup('SkipLspAutomaticFormatting', {})

function M.has_open_focusable_float()
  for _, winid in pairs(vim.api.nvim_tabpage_list_wins(0)) do
    local config = vim.api.nvim_win_get_config(winid)
    if config.relative ~= '' and config.focusable then
      return true
    end
  end
  return false
end

-- setup a buffer with an lsp server attached with the proper mappings and
-- options
function M.setup_lsp_buf(client, bufnr)
  -- NOTE "format on save" is handled by conform
  -- buffer-local options {{{
  vim.bo[bufnr].omnifunc = 'v:lua.vim.lsp.omnifunc'
  vim.bo[bufnr].formatexpr = '' -- reserve gq for comment formatting
  -- }}}
  -- buffer-local maps {{{

  ---@alias Keymap - mirrors params that you pass to `vim.keymap.set`
  ---| { [1]: string|string[], [2]: string, [3]: string|fun(), [4]?: vim.keymap.set.Opts }
  ---@type Keymap[]
  local buf_maps = {
    { 'n', '<C-]>', vim.lsp.buf.definition },
    {
      'n',
      '<leader>la',
      vim.lsp.buf.code_action,
      { desc = 'LSP code actions' },
    },
    { 'n', '<leader>lr', vim.lsp.buf.rename, { desc = 'LSP rename symbol' } },
    {
      'n',
      '<leader>li',
      function()
        vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled(nil))
      end,
      { desc = 'Toggle LSP inlay hints' },
    },
    {
      'n',
      '<leader>lz',
      vim.lsp.codelens.run,
      { desc = 'Run LSP codelens' },
    },
  }

  for _, mapping in ipairs(buf_maps) do
    mapping[4] = vim.tbl_extend('force', mapping[4] or {}, {
      buffer = bufnr,
    })
    vim.keymap.set(unpack(mapping))
  end
  -- }}}
  -- buffer-local autocmds {{{
  vim.api.nvim_create_autocmd('CursorHold', {
    buffer = bufnr,
    desc = 'Open diagnostic float when holding cursor',
    callback = function()
      if M.has_open_focusable_float() then
        return
      end

      vim.diagnostic.open_float(
        nil,
        { scope = 'line', source = 'if_many', focusable = false, focus = false }
      )
    end,
  })

  local function lsp_buf_autocmd(...)
    local event, opts = ...
    opts.buffer = bufnr
    opts.group = M.buf_lsp_augroup
    vim.api.nvim_create_autocmd(event, opts)
  end

  if client.server_capabilities.codeLensProvider then
    lsp_buf_autocmd({ 'BufEnter', 'CursorHold', 'InsertLeave' }, {
      callback = function()
        vim.lsp.codelens.refresh({ bufnr = bufnr })
      end,
      desc = '<setup_lsp_buf> Refresh code lens',
    })
  end
  if client.server_capabilities.documentHighlightProvider then
    lsp_buf_autocmd({ 'CursorHold', 'CursorHoldI' }, {
      callback = function()
        vim.lsp.buf.document_highlight()
      end,
      desc = '<setup_lsp_buf> Document highlight when holding',
    })
    lsp_buf_autocmd('CursorMoved', {
      callback = function()
        vim.lsp.buf.clear_references()
      end,
      desc = '<setup_lsp_buf> Clear references when moving',
    })
  end

  -- }}}
end

M.lsp_banned_roots = {
  '^/nix/store/',
  -- '%.cargo/registry',
  -- 'node_modules/'
  --
  -- let these^^ through for now, i wanna navigate between symbols in *.d.ts
  -- files TODO(skip): make something more elaborate, because LSP is probably
  -- OK in library files but not null-ls (or equiv.)
}

function M.attach_allowed(bufnr)
  local bufname = vim.api.nvim_buf_get_name(bufnr)
  local shortened_bufname = vim.fn.pathshorten(bufname, 2)

  -- i'd add some cute messages here, but this function can be called more than
  -- once and i don't want to trigger the hit-enter-prompt

  if utils.is_flag_set(M.noattach_key, bufnr) then
    -- buffer is explicitly flagged as not wanting LSPs
    vim.notify(
      ('not attaching: %s (flag)'):format(shortened_bufname),
      vim.log.levels.WARN
    )
    return false
  end

  for _, banned_pattern in ipairs(M.lsp_banned_roots) do
    if bufname:find(banned_pattern) then
      vim.notify(
        ('not attaching: %s (%s)'):format(shortened_bufname, banned_pattern),
        vim.log.levels.WARN
      )
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

        if client.name == 'metals' then
          -- handle via `metals_config.on_attach` instead
          return
        end

        local bufnr = args.buf

        M.setup_lsp_buf(client, bufnr)

        vim.schedule(function()
          vim.notify(
            string.format('"%s"<%d> (o_o)/ #%d', client.name, client.id, bufnr),
            vim.log.levels.INFO
          )
        end)
      end,
      desc = 'Sets up autocmds and mappings for buffers that use LSP',
    },
  },
  {
    'LspProgress',
    {
      desc = 'Report LSP progress to terminal via OSC 9;4',
      callback = function(ev)
        local value = ev.data.params.value or {}

        local msg = value.message or 'done'
        local did_trunc
        msg, did_trunc = utils.trunc_codepoints(msg, 40)
        if did_trunc then
          msg = msg .. '… '
        end

        if value.kind == 'end' then
          utils.term_progress('remove')
        else
          if value.percentage then
            utils.term_progress('running', value.percentage)
          else
            utils.term_progress('indeterminate')
          end
        end
      end,
    },
  },
  {
    'VimLeavePre',
    {
      desc = 'Remove reported LSP progress from terminal via OSC 9;4',
      callback = function()
        utils.term_progress('remove')
      end,
    },
  },
})

M.capabilities = {}

local function try_adding_capabilities(get_capabilities)
  local ok, caps = pcall(get_capabilities)
  if ok and caps then
    M.capabilities = vim.tbl_deep_extend('force', M.capabilities, caps)
    return true
  end
  return false
end

if
  not try_adding_capabilities(function()
    return require('cmp_nvim_lsp').default_capabilities()
  end)
then
  try_adding_capabilities(function()
    return require('blink.cmp').get_lsp_capabilities()
  end)
end
try_adding_capabilities(function()
  return require('lsp-file-operations').default_capabilities()
end)

return M

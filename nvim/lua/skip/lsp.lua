local utils = require("skip.utils")

local M = {}

local function map_buf(mode, key, result, opts)
  vim.keymap.set(
    mode,
    key,
    result,
    vim.tbl_extend("force", { buffer = true, remap = false, silent = true }, opts or {})
  )
end

M.noattach_key = "LSP_NOATTACH"
M.noformat_key = "LSP_NOFORMAT"

M.formatting_augroup = vim.api.nvim_create_augroup("SkipLspAutomaticFormatting", {})

function M.has_open_focusable_float()
  for _, winid in pairs(vim.api.nvim_tabpage_list_wins(0)) do
    local config = vim.api.nvim_win_get_config(winid)
    if config.relative ~= "" and config.focusable then
      return true
    end
  end
  return false
end

-- setup a buffer with an lsp server attached with the proper mappings and
-- options
function M.setup_lsp_buf(client, bufnr)
  if client.server_capabilities.codeLensProvider then
    vim.cmd([[autocmd BufEnter,CursorHold,InsertLeave <buffer> lua vim.lsp.codelens.refresh()]])
  end

  vim.bo.omnifunc = "v:lua.vim.lsp.omnifunc"
  vim.bo.formatexpr = "" -- reserve gq for comment formatting

  -- will ship with Nvim 0.11:
  -- map_buf("n", "grn", vim.lsp.buf.rename)
  -- map_buf("n", "grr", vim.lsp.buf.references)
  -- map_buf("n", "gri", vim.lsp.buf.implementation)
  -- map_buf("n", "gra", vim.lsp.buf.code_action)
  -- map_buf("i", "<C-S>", vim.lsp.buf.signature_help)

  map_buf("n", "<C-]>", vim.lsp.buf.definition)
  map_buf("n", "<leader>la", vim.lsp.buf.code_action, { desc = "LSP code actions" })
  map_buf("n", "<leader>lr", vim.lsp.buf.rename, { desc = "LSP rename symbol" })
  map_buf("n", "<leader>li", function()
    vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled(nil))
  end, { desc = "Toggle LSP inlay hints" })
  map_buf("n", "<leader>lz", vim.lsp.codelens.run, { desc = "Run LSP codelens" })

  vim.api.nvim_create_autocmd('CursorHold', {
    buffer = bufnr,
    desc = 'Open diagnostic float when holding cursor',
    callback = function()
      if M.has_open_focusable_float() then return end
      vim.diagnostic.open_float(nil, { scope = "line", source = "if_many", focusable = false, focus = false })
    end
  })

  -- vim.api.nvim_create_autocmd('BufWritePre', {
  --   buffer = bufnr,
  --   desc = 'Automatically LSP format before writing buffer',
  --   callback = function()
  --     local is_fugitive_buf = vim.api.nvim_buf_get_name(bufnr):find "fugitive://" == 1
  --     if utils.flag_set(M.noformat_key) or is_fugitive_buf then return end
  --
  --     vim.lsp.buf.format { timeout_ms = 500, bufnr = bufnr }
  --   end
  -- })
end

M.banned_patterns = {
  "^/nix/store/",
  "%.cargo/registry",
  -- 'node_modules/'
  -- let this through for now, i wanna navigate between symbols in *.d.ts files
  -- TODO: make something more elaborate, because LSP is probably OK in library
  -- files but not null-ls (or equiv.)
}

-- we patch lspconfig.util.bufname_valid to call this
function M.attach_allowed(bufnr)
  local bufname = vim.api.nvim_buf_get_name(bufnr)

  -- i'd add some cute messages here, but this function can be called more than
  -- once and i don't want to trigger the hit-enter-prompt

  -- if utils.flag_set(M.noattach_key) then
  if utils.flag_set(M.noattach_key, bufnr) then
    vim.notify(("attach_allowed: REFUSING buffer %d (%s), flag was set"):format(bufnr, bufname), vim.log.levels.WARN)
    return false
  end

  for _, banned_pattern in ipairs(M.banned_patterns) do
    if bufname:find(banned_pattern) then
      vim.notify(
        ("attach_allowed: REFUSING buffer %d (%s), matched banned pattern %s"):format(bufnr, bufname, banned_pattern),
        vim.log.levels.WARN
      )
      return false
    end
  end

  return true
end

utils.autocmds("SkipLsp", {
  {
    "LspAttach",
    {
      pattern = "*",
      callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if not client then
          return
        end
        local bufnr = args.buf

        M.setup_lsp_buf(client, bufnr)

        vim.schedule(function()
          vim.notify(
            string.format("(^_^)/ %s (%d) attached to buf %d", client.name, client.id, bufnr),
            vim.log.levels.INFO
          )
        end)
      end,
      desc = "Sets up autocmds and mappings for buffers that use LSP",
    },
  },
})


M.capabilities = {}

local function try_adding_capabilities(module)
  local ok, module = pcall(require, module)
  if ok then
    M.capabilities = vim.tbl_deep_extend('force', M.capabilities, module.default_capabilities())
  end
end

try_adding_capabilities('cmp_nvim_lsp')
try_adding_capabilities('lsp-file-operations')

return M

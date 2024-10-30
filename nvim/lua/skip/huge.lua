local lsp = require('skip.lsp')
local utils = require('skip.utils')

local M = {}

M.bypass_key = 'HUGE_BYPASS'

-- actual consumption of these constants is outside of this file... fixme pls
M.limits = {
  max_lines = 10000,
  max_file_size_bytes = 1000000,
  max_individual_line_length = 500,
}

---@param bufnr number
---@param reason string?
---@param opts { silently: boolean }?
function M.bounce(bufnr, reason, opts)
  local silent ---@type boolean
  if opts ~= nil then
    silent = opts.silently
  else
    silent = false
  end

  if utils.flag_set(M.bypass_key, bufnr) then
    if not silent then
      vim.notify(
        ('huge: not bouncing this buffer (%d), bypass flag set'):format(bufnr),
        vim.log.levels.INFO
      )
    end
    return
  end

  -- general flag (also disables cmp)
  vim.b[bufnr].huge_bounced = true

  -- prevent LSPs from attaching or acting on the buffer
  vim.b[bufnr][lsp.noattach_key] = true
  vim.b[bufnr][lsp.noformat_key] = true

  -- disable plugins
  vim.b[bufnr].miniindentscope_disable = true

  -- disable plain (non-tree sitter) syntax highlighting
  vim.b[bufnr].current_syntax = '' -- equivalent to :syntax clear (hopefully)
  vim.schedule(function()
    vim.b[bufnr].current_syntax = ''
  end) -- and i'd do it again
  vim.schedule(function()
    vim.cmd [[syntax clear]]
  end) -- and i'd do it again

  local formatted_reason = reason and ('reason: %s'):format(reason)
    or 'no resaon'
  if not silent then
    vim.notify(
      ('huge: BOUNCING buffer %d (%s)'):format(bufnr, formatted_reason),
      vim.log.levels.WARN
    )
  end

  -- :)
  vim.o.eventignore = 'FileType'
  vim.schedule(function()
    vim.o.eventignore = ''
  end)
end

---@param bufnr number
---@param opts { silently: boolean }?
function M.bouncer(bufnr, opts)
  if vim.api.nvim_buf_line_count(bufnr) > M.limits.max_lines then
    M.bounce(bufnr, 'too many lines', opts)
    return true
  end

  local stats = vim.fn.wordcount()
  if stats.bytes > M.limits.max_file_size_bytes then
    M.bounce(bufnr, 'too many bytes', opts)
    return true
  end

  for _, file_line in pairs(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)) do
    if #file_line > M.limits.max_individual_line_length then
      M.bounce(
        bufnr,
        ('some line longer than %d'):format(M.limits.max_individual_line_length),
        opts
      )
      return true
    end
  end

  return false
end

return M

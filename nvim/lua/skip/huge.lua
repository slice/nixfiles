-- logic/design mostly cribbed from folke/snacks.nvim:
-- https://github.com/folke/snacks.nvim/blob/9912042fc8bca2209105526ac7534e9a0c2071b2/lua/snacks/bigfile.lua

local lsp = require('skip.lsp')
local utils = require('skip.utils')

local M = {}

-- filetype used for huge files
--
-- to detect if a file was bounced, use is_bounced
M.filetype = 'huge'

M.augroup = vim.api.nvim_create_augroup('SkipHuge', { clear = true })

-- name of a buffer-scoped (`b:` or `vim.b`) variable that indicates that the
-- buffer was bounced
M.bufvar = 'huge_bounced'

-- name of a variable that may be set (either globally or per-buffer) to grant
-- immunity to bouncing
M.immunity_flag = 'huge_immune'

-- actual consumption of these constants is outside of this file... fixme pls
M.limits = {
  max_lines = 20000,
  max_file_size_bytes = 1.5 * 1024 * 1024,
  max_average_line_length = 1000,
}

---@param bufnr number
---@param original_ft string?
function M.bounce(bufnr, original_ft)
  -- general flag that others may observe
  vim.b[bufnr][M.bufvar] = true

  -- prevent LSPs from attaching or acting on the buffer
  vim.b[bufnr][lsp.noattach_key] = true
  vim.b[bufnr][lsp.noformat_key] = true

  -- disable plugins
  vim.b[bufnr].completion = false -- blink-cmp
  vim.b[bufnr].miniindentscope_disable = true -- mini.indentscope
  vim.b[bufnr].minihipatterns_disable = true -- mini.hipatterns

  -- disable MatchParen which constantly seeks through buf text
  --
  -- NOTE it sucks that we can't specify the bufnr to act on here, but bouncing
  -- is called from `vim.filetype` right now so eehhhh
  if vim.fn.exists(':NoMatchParen') ~= 0 then
    vim.cmd([[NoMatchParen]])
  end

  -- set up syntax after a tick (because we overwrite the ft with `huge`)
  if original_ft then
    vim.schedule(function()
      if vim.api.nvim_buf_is_valid(bufnr) then
        vim.bo[bufnr].syntax = original_ft
      end
    end)
  end
end

--- sets up the bouncer via `vim.filetype`, like snacks.nvim does
function M.setup()
  local function filetype(path, bufnr)
    if not path or not bufnr then
      return
    end

    local verdict, reason = M.should_bounce(bufnr)
    if not verdict then
      -- couldn't figure it out, or we shouldn't bounce -- let other
      -- handlers take over
      return
    end

    local short_path = utils.shorten(path)
    vim.notify(
      ('🏀 bouncing #%d %s because %s'):format(bufnr, short_path, reason),
      vim.log.levels.WARN
    )
    return M.filetype
  end

  vim.filetype.add({ pattern = { ['.*'] = { filetype } } })

  vim.api.nvim_create_autocmd({ 'FileType' }, {
    group = M.augroup,
    pattern = M.filetype,
    desc = 'Disables plugins for buffers containing huge files',
    callback = function(ctx)
      vim.api.nvim_buf_call(ctx.buf, function()
        M.bounce(ctx.buf, vim.filetype.match({ buf = ctx.buf }))
      end)
    end,
  })
end

---@param bufnr number
---@return boolean
function M.was_bounced(bufnr)
  return vim.bo[bufnr].filetype == M.filetype or vim.b[bufnr][M.bufvar]
end

---@param bufnr number
---@return boolean | nil, string a reason string, and whether it should be bounced or not (`nil` if buf is invalid somehow)
function M.should_bounce(bufnr)
  if utils.is_flag_set(M.immunity_flag, bufnr) then
    return false, 'buf is immune'
  end

  if not vim.api.nvim_buf_is_loaded(bufnr) then
    return nil, 'buf not loaded'
  end
  if M.was_bounced(bufnr) then
    return false, 'already bounced'
  end

  ------------------------------------------------------------------------------

  local line_count = vim.api.nvim_buf_line_count(bufnr)
  if line_count > M.limits.max_lines then
    return true, ('too many lines (%d)'):format(line_count)
  end

  local path = vim.fs.normalize(vim.api.nvim_buf_get_name(bufnr))
  if not path then
    -- seemingly true for telescope preview buffers, and probably other stuff
    return nil, "buf doesn't have a path"
  end

  local size = vim.fn.getfsize(path)
  if size <= 0 then
    return nil, "couldn't get fsize"
  end
  if size > M.limits.max_file_size_bytes then
    return true, ('too many bytes (%d)'):format(size)
  end

  local n_lines = vim.api.nvim_buf_line_count(bufnr)
  local avg_line_len = (size - n_lines) / n_lines

  if avg_line_len > M.limits.max_average_line_length then
    return true,
      ('average line length too long (%f > %d)'):format(
        avg_line_len,
        M.limits.max_average_line_length
      )
  end

  return false, 'OK'
end

return M

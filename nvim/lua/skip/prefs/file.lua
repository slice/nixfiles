local utils = require 'skip.utils'

local M = {}

function M._should_try_loading_for(path)
  if not vim.startswith(path, '/') then
    -- only care about real files on the fs
    -- (this probably won't work on windows)
    return false
  end

  return true
end

M._filename = '.prefs.lua'

--- Locates a prefs file that a buffer should attempt to load from. The file
--- may or may not exist.
---
--- For buffers backed by a file, the search starts from its associated file
--- path (thus "project" prefs files are consistently applied); otherwise, the
--- search starts from the current directory.
---
--- @param bufnr integer
--- @return string?
function M._locate_prefs_file(bufnr)
  local root = vim.fs.root(bufnr, {
    function(name, _)
      return name == M._filename
    end,
    { '.git', '.jj' },
  })

  if not root then
    return
  end

  return vim.fs.joinpath(root, M._filename)
end

--- @param path string
--- @return skip.Prefs
function M._load_from_path(path)
  ---@diagnostic disable-next-line: param-type-mismatch
  local chunk, err = loadfile(path)

  if err then
    error(err)
  end
  if not chunk then
    error('loaded chunk was nil')
  end

  -- TODO(skip): Validate.
  local evaled = chunk()
  local typ = type(evaled)
  if typ ~= 'table' then
    error(
      ("prefs file %s doesn't return a table (got %s instead)"):format(
        path,
        typ
      )
    )
  end

  return evaled
end

---@type skip.PrefResolver
function M._resolver(ctx, prev)
  if not ctx.bufnr then
    return prev
  end
  if not M._should_try_loading_for(ctx.path) then
    return prev
  end

  local prefs_file_path = M._locate_prefs_file(ctx.bufnr)
  if not prefs_file_path then
    -- could not even find a git root or anything
    return prev
  end

  local ok, res = pcall(M._load_from_path, prefs_file_path)
  if not ok then
    local ok_errors =
      { '(got nil instead)', 'No such file', 'Permission denied' }

    if utils.str_contains(res, ok_errors) then
      -- suppress
      return prev
    end

    error(res)
  end

  return vim.tbl_deep_extend('force', prev, res)
end

--- @type skip.PrefSource
M.source = {
  name = '.prefs.lua loader',
  prefs = M._resolver,
}

return M

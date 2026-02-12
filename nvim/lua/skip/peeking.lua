-- make it clearer when a file isn't part of the code we're working on

local M = {}
local autocmds = require('skip.utils').autocmds

-- any buffer that points to a file within any of these paths will be
-- considered to be "peeking"
--
-- the paths are resolved (including symlinks and "~")
M.peeking_roots = {
  '~/go/pkg',
  '/nix/store',
}

-- for buffers determined to be peeking, each group listed here is replaced
-- with the itself but with "Peek" at the end. e.g. Normal -> NormalPeek.
M.hl_groups = { 'Normal', 'CursorLine' }

--------------------------------------------------------------------------------

function M.resolve(path)
  local resolved = vim.uv.fs_realpath(vim.fs.abspath(path))
  if resolved == nil then
    error("couldn't resolve: " .. path)
  end
  return resolved
end

---@return boolean
function M.path_is_peek(path)
  if vim.startswith(path, 'minifiles://') then
    -- mini.files needs to set `winhighlight` and is really prone to setting a
    -- corrupted value, so don't touch them at all
    --
    -- (not like we really needed them, though)
    return false
  end

  local is_peeking = false

  for _, prefix in ipairs(M.peeking_roots) do
    -- always re-resolve in case paths swap out since being set (probably rare)
    local resolved_prefix = M.resolve(prefix)

    if vim.startswith(path, resolved_prefix) then
      is_peeking = true
    end
  end

  return is_peeking
end

function M.update(bufnr)
  if
    not vim.api.nvim_buf_is_valid(bufnr)
    or not vim.api.nvim_buf_is_loaded(bufnr)
  then
    -- no point in actually updating
    return
  end

  local buf_path = vim.api.nvim_buf_get_name(bufnr)
  -- vim.notify(buf_path, vim.log.levels.INFO)

  if M.path_is_peek(buf_path) then
    -- TODO(skip): Don't smash values that might already be here.
    local winhl = vim
      .iter(M.hl_groups)
      :map(function(g)
        return ('%s:%sPeek'):format(g, g)
      end)
      :join(',')
    vim.wo.winhighlight = winhl
  else
    vim.wo.winhighlight = ''
  end
end

autocmds('SkipPeeking', {
  {
    { 'BufEnter' },
    {
      callback = function(args)
        local bufnr = args.buf
        M.update(bufnr)
      end,
    },
  },
})

return M

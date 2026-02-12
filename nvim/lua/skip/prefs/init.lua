-- DESIGN NOTES
--
-- initially i considered writing M._apply(ctx) and having that e.g. call
-- require'conform'.setup{}, but i don't want to constantly reconfigure
-- plugins; not all of them are amenable to dynamic reconfiguration like that,
-- either. so instead we can configure the plugins once and use any function
-- callbacks they (hopefully) expose to read the currently effective prefs and
-- act based on that.
--
-- also: by constantly reevaluating prefs (i.e. not applying them statefully),
-- we get reloading for free should a pref source read from a file or something
-- like that. (not doing caching atm)
--
-- TODO(skip): track provenance information (tell where a pref came from)

--------------------------------------------------------------------------------

--- A mergeable set of options that may be applied to influence editor and
--- plugin behavior.
--- @class skip.Prefs
--- @field format_on_save? boolean When true, invokes conform.nvim before writing buffers
--- @field extra? table<string, any> Arbitrary information that is merged like all other data.

--- Data that may influence how the set of effective prefs are resolved.
--- @class skip.PrefsCtx
--- @field cwd? string The effective current directory
--- @field path? string Current buffer's full file name
--- @field bufnr? number Current buffer's globally unique identifier
--- @field winid? number Current window's globally unique identifier
--- @field winnr? number Current window's tabpage-local identifier
--- @field tabnr? number Current tabpage's globally unique identifier

--- Dynamically vends prefs for more control. The returned prefs overwrites the
--- final set, so be sure to use tbl_deep_extend with prev if you don't wish to
--- clobber all previously evaluated prefs.
--- @alias skip.PrefSourceFn fun(ctx: skip.PrefsCtx, prev: skip.Prefs): skip.Prefs

--- @alias skip.PrefResolver (skip.Prefs | skip.PrefSourceFn)

--- @class skip.PrefSource
--- @field prefs skip.PrefResolver Preferences to be used
--- @field name string A human-readable name

--- @class skip.PrefsModule: skip.Prefs
local M = {}

-- Used for autocomplete suggestions. Keep this in sync with the
-- type of skip.Prefs.
M._pref_keys = {
  'format_on_save',
}

--- @return skip.PrefsCtx
function M._current_ctx()
  local winid = vim.fn.win_getid()
  local winnr = vim.fn.win_id2win(winid)
  if winnr == 0 then
    error('win_id2win failed')
  end
  local tabnr = vim.fn.tabpagenr()
  if tabnr == 0 then
    error('tabpagenr() failed')
  end
  local bufnr = vim.api.nvim_get_current_buf()

  local cwd = vim.fn.getcwd(winnr, tabnr)
  local path = vim.api.nvim_buf_get_name(bufnr)

  return {
    cwd = cwd,
    path = path,
    bufnr = bufnr,
    winid = winid,
    winnr = winnr,
    tabnr = tabnr,
  }
end

--- @type skip.PrefSource[]
M.sources = require 'skip.prefs.sources'

--- Computes an authoritative set of prefs to apply for a given context.
--- @param ctx? skip.PrefsCtx
--- @return skip.Prefs
function M._resolve_prefs(ctx)
  ctx = ctx or M._current_ctx()

  --- @type skip.Prefs
  local final = {}

  for _, source in pairs(M.sources) do
    --- @type skip.Prefs
    if type(source.prefs) == 'function' then
      local gen = source.prefs --[[@as skip.PrefSourceFn]]
      local ok, next = pcall(gen, ctx, final)
      if not ok then
        error(('_resolve_prefs failed for %s: %s'):format(source.name, next))
      end
      final = next
    else
      local prefs = source.prefs --[[@as skip.Prefs]]
      final = vim.tbl_deep_extend('force', final, prefs)
    end
  end

  return final
end

-- permits quick usage: require'skip.prefs'.my.cool.pref
setmetatable(M, {
  __index = function(_, key)
    -- infer from current context
    local prefs = M._resolve_prefs()
    if prefs[key] then
      -- vim.notify(
      --   ('<prefs> "%s" => %s'):format(key, prefs[key]),
      --   vim.log.levels.INFO
      -- )
      return prefs[key]
    end

    return nil
  end,
})

return M

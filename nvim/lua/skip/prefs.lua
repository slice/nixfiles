local M = {}

---@alias SkipPrefsFormattingLSPBehavior
---| '"prefer"' # Attempt LSP formatting first, falling back to `cmds`. If LSP formatting succeeds, `cmds` is unused.
---| '"only"' # Only ever attempt LSP formatting, never attempt `cmds`.
---| '"before_cmds"' # Treat LSP formatting as if it were the first entry in `cmds`.
---| '"after_cmds"' # Treat LSP formatting as if it were the last entry in `cmds`.

---@class SkipPrefsFormatting
---@field cmds string[] A table of binary names or paths which are attempted in sequence
---@field lsp SkipPrefsFormattingLSPBehavior Whether to attempt LSP formatting

---@class SkipPrefs
---@field fmt SkipPrefsFormatting Command-line executables automatically invoked to replace file content for indentation and automatic fixes

---@class SkipPrefsContext
---@field bufnr number The current buffer
---@field winid number The window ID (can refer to any window in any tab)
---@field winnr number The window number (local to a given tab)
---@field tabpagenr number The number of the current tab page

---@class SkipPrefsSource
---@field prefs (SkipPrefs | fun(ctx: SkipPrefsContext): SkipPrefs) Vends some preferences to be used
---@field name string The name of this source

---@type SkipPrefsSource[]
M.sources = {
  {
    name = 'testing :D',
    prefs = { nice = 2 }
  }
}

---@return SkipPrefsContext
function M._get_context()
  local winid = vim.fn.win_getid()
  local winnr = vim.fn.win_id2win(winid)
  if winnr == 0 then error('win_id2win failed') end
  local tabpagenr = vim.fn.tabpagenr()
  if tabpagenr == 0 then error('tabpagenr() failed') end

  return {
    bufnr = vim.api.nvim_get_current_buf(),
    winid = winid,
    winnr = winnr,
    tabpagenr = tabpagenr,
  }
end

---@param custom_ctx SkipPrefsContext
function M._resolve_prefs(custom_ctx)
  local ctx = custom_ctx == nil and M._get_context() or custom_ctx

  local prefs = {}

  for source in M.sources do
    local ok, result = pcall(source, ctx)
    if ok then
      local source_prefs = type(result) == "function" and result(ctx) or result
      if type(source_prefs) ~= "table" then
        error("_resolve_prefs failed for " .. source.name .. ": resultant prefs wasn't a table")
      end
      prefs = vim.tbl_deep_extend('force', prefs, source_prefs)
    else
      error("_resolve_prefs failed for " .. source.name .. ": " .. tostring(result))
    end
  end

  return prefs
end

setmetatable(M, {
  __index = M._resolve_pref_value,
})


return M

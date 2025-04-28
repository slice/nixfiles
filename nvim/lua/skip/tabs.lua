local utils = require('skip.utils')

local M = {}

function M.shorten_path(path)
  if not path then
    return path
  end

  return utils.shorten(path, { max = 4 })
end

function M.tab_display_name(tabid)
  local tabnr = vim.api.nvim_tabpage_get_number(tabid)

  local winids = vim
    .iter(vim.api.nvim_tabpage_list_wins(tabid))
    -- only want normal windows (i.e. no popups/floating)
    :filter(
      function(winid)
        local config = vim.api.nvim_win_get_config(winid)
        local focusable = config.focusable == nil or config.focusable == true

        -- testing `config.relative` doesn't really work for some reason, this
        -- is much more reliable (`win_gettype` seemingly accepts both winnrs
        -- and winids)
        local is_normal_win = vim.fn.win_gettype(winid) == ''

        return vim.api.nvim_win_is_valid(winid) and focusable and is_normal_win
      end
    )
    :totable()

  -- tracks seen cwds
  local seen = {}
  local seen_icons = {}

  for _, winid in ipairs(winids) do
    -- `getcwd` works for both winnrs and winids
    local cwd = vim.fn.getcwd(winid, tabnr)

    if cwd and not seen[cwd] then
      -- witness this cwd
      seen[cwd] = true
    end

    -- attempt to resolve the icon for the window's buffer
    local bufid = vim.api.nvim_win_get_buf(winid)
    local fname = vim.api.nvim_buf_get_name(bufid)
    local ext = fname:match('%.(%w+)$')
    local file_icon =
      require('nvim-web-devicons').get_icon(fname, ext, { default = true })
    if file_icon then
      seen_icons[file_icon] = true
    end
  end

  if vim.tbl_isempty(seen) then
    return '?'
  end

  local cwds = vim.tbl_keys(seen)

  -- make sure seen cwd set ordering is stable
  table.sort(cwds, function(a, b)
    return a:lower() < b:lower()
  end)
  -- format tabs like "[/things/cwd|/things/other/cwd]"
  local viz = ('[%s]'):format(
    -- shorten the cwd
    table.concat(vim.iter(cwds):map(M.shorten_path):totable(), '|')
  )
  -- if there was only ever one filetype icon in the entire tab, then replicate
  -- it here
  if #vim.tbl_keys(seen_icons) == 1 then
    viz = next(seen_icons) .. ' ' .. viz
  end

  -- only one window in this tab, try displaying its only buffer's filename
  -- relative to the cwd and shortened
  if #winids == 1 then
    local winnr = winids[1]
    local only_bufnr = vim.fn.winbufnr(winnr)
    if only_bufnr ~= -1 then
      local only_cwd = cwds[1]

      local only_path = vim.api.nvim_buf_get_name(only_bufnr)
      local only_relpath = vim.fs.relpath(only_cwd, only_path)
      local tab_only_file_viz = M.shorten_path(only_relpath)
        or M.shorten_path(only_path)

      viz = viz .. ':' .. tab_only_file_viz
    end
  end

  return viz
end

function M.custom_tabline()
  local tabline = ''

  for _, tabid in ipairs(vim.api.nvim_list_tabpages()) do
    if vim.api.nvim_tabpage_is_valid(tabid) then
      local tabnr = vim.api.nvim_tabpage_get_number(tabid)

      local tab_color
      local tabnr_color = '%#MatchParen#'
      if tabid == vim.api.nvim_get_current_tabpage() then
        -- tab is active
        tab_color = '%#TabLineSel#'
      else
        tab_color = '%#TabLine#'
      end

      local cur = ('%s%s %s%d%s %s '):format(
        tab_color,
        -- this defines the click target for the mouse
        ('%' .. tostring(tabnr) .. 'T'),
        tabnr_color,
        vim.api.nvim_tabpage_get_number(tabid),
        tab_color,
        M.tab_display_name(tabid)
      )

      tabline = tabline .. cur
    end
  end

  -- fill out the rest of the tabline so it doesn't end at the last tab
  tabline = tabline .. '%#TabLineFill#'

  return tabline
end

_G._skip_tabs = M

vim.opt.tabline = '%!v:lua._skip_tabs.custom_tabline()'

M.augroup_id = vim.api.nvim_create_augroup('SkipTabs', {})
-- vim.api.nvim_create_autocmd({
--   'WinNew',
--   'WinClosed',
--   'DirChanged',
-- }, {
--   group = M.augroup_id,
--   desc = 'Redraws tabline as necessary',
--   callback = function()
--     local redraw = vim.api.nvim__redraw
--     if redraw then
--       redraw({
--         tabline = true,
--         valid = true,
--         flush = false,
--       })
--     else
--       vim.cmd [[redraw]]
--     end
--   end,
-- })
--
return M

local M = {}

local home = vim.fs.normalize('~')

function M.tab_display_name(tabid)
  local winnrs = vim.api.nvim_tabpage_list_wins(tabid)
  local seen = {}

  for _, winnr in ipairs(winnrs) do
    local cwd = vim.fn
      .getcwd(winnr, vim.api.nvim_tabpage_get_number(tabid))
      :gsub(vim.pesc(home), '~')
    cwd = cwd:gsub('~/Developer', '*'):gsub('~/src', '*')
    local shortened_cwd = vim.fn.pathshorten(cwd, 12)

    if shortened_cwd and not seen[shortened_cwd] then
      seen[shortened_cwd] = true
    end
  end

  if vim.tbl_isempty(seen) then
    return '...'
  end

  local cwds = vim.tbl_keys(seen)
  table.sort(cwds, function(a, b)
    return a:lower() < b:lower()
  end)
  local tab_viz = ('[%s]'):format(table.concat(cwds, '|'))
  if #winnrs == 1 then
    local winnr = winnrs[1]
    local only_bufnr = vim.fn.winbufnr(winnr)
    if only_bufnr ~= -1 then
      local tab_only_file_viz =
        vim.fn.pathshorten(vim.api.nvim_buf_get_name(only_bufnr), 3)
      tab_viz = tab_viz .. '::' .. tab_only_file_viz
    end
  end

  return tab_viz
end

function M.custom_tabline()
  local tabline_string = ''

  for _, tabid in ipairs(vim.api.nvim_list_tabpages()) do
    if vim.api.nvim_tabpage_is_valid(tabid) then
      local tab_color
      local tabnr_color = '%#MatchParen#'
      if tabid == vim.api.nvim_get_current_tabpage() then
        -- tab is active
        tab_color = '%#TabLineSel#'
      else
        tab_color = '%#TabLine#'
      end

      local current_tab_text = ('%s %s%d%s %s '):format(
        tab_color,
        tabnr_color,
        vim.api.nvim_tabpage_get_number(tabid),
        tab_color,
        M.tab_display_name(tabid)
      )
      tabline_string = tabline_string .. current_tab_text
    end
  end

  tabline_string = tabline_string .. '%#TabLineFill#'

  return tabline_string
end

_G._skip_tabs = M

vim.opt.tabline = '%!v:lua._skip_tabs.custom_tabline()'

return M

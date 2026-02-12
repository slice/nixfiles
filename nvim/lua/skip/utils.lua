local M = {}

-- from: https://github.com/wbthomason/dotfiles/blob/5117f6d76c64baa661368e85a25ca463ff858a05/neovim/.config/nvim/lua/config/utils.lua
--- @param group_name string augroup name
--- @param parameter_packs ({ [1]: (string | string[]), [2]: vim.api.keyset.create_autocmd }[] | string)
function M.autocmds(group_name, parameter_packs)
  if type(parameter_packs) == 'string' then
    parameter_packs = { parameter_packs }
  end

  local group_id = vim.api.nvim_create_augroup(group_name, {})

  for _, pack in ipairs(parameter_packs) do
    -- 2nd argument is the table passed to nvim_create_autocmd
    pack[2].group = group_id
    vim.api.nvim_create_autocmd(unpack(pack))
  end
end

--- @param haystack string
--- @param needle string
--- @return boolean
local function _str_contains(haystack, needle)
  return string.find(haystack, needle, 1, true) ~= nil
end

--- @param haystack string
--- @param needles string|string[]
--- @return boolean
function M.str_contains(haystack, needles)
  if type(needles) == 'table' then
    for _, needle in ipairs(needles) do
      if _str_contains(haystack, needle) then
        return true
      end
    end

    return false
  end

  return _str_contains(haystack, needles)
end

function M.path_from_segments(segs, prepending_root_slash)
  if prepending_root_slash == nil then
    prepending_root_slash = true
  end

  local joined = table.concat(segs, '/')
  if prepending_root_slash and joined:sub(1, 1) ~= '~' then
    joined = '/' .. joined
  end
  return joined
end

local home = vim.fs.abspath('~')

-- M.shorten will replace these path prefixes with a hammer symbol when
-- encountered
M.symbolized_work_roots = {
  '~/Developer',
  '~/src',
  '/Volumes/Shared/Developer',
  '/Volumes/Shared/work',
}

local _symbols = {
  hammer = ' ',
  neovim = ' ',
  nix = '󱄅 ',
}

--- @param path string
--- @param opts? { max_segment_len?: number, return_separated_tail?: boolean }
--- @return string|string[]
function M.shorten(path, opts)
  opts = opts or {}
  local seg_max = opts.max_segment_len or 16
  assert(seg_max > 0)
  local symbolized = path:gsub(vim.pesc(home), '~')
  for _, root in ipairs(M.symbolized_work_roots) do
    symbolized = symbolized:gsub(vim.pesc(root), _symbols.hammer)
  end

  -- initializing it to this is gross but avoids having to do "contains then gsub"
  -- in the loop above
  local did_abridge = M.str_contains(symbolized, _symbols.hammer)

  local segs = vim.split(symbolized, '/', { plain = true, trimempty = true })

  -- detect nix store paths, replacing "/nix/store/zzzz-pkg-ver/..." => "󱄅  pkg-ver/"
  -- (except for neovim, which gets " /" instead)
  if segs[1] == 'nix' and segs[2] == 'store' then
    local dir_name = segs[3] -- e.g. "zi06f4k47xw8wmycp9sav5g25bqrqzzw-neovim-unwrapped-0.11.6"
    -- chop off /nix/store/hash-name-ver
    segs = vim.list_slice(segs, 4, #segs)

    local pkg_name = dir_name
    pkg_name = pkg_name:sub(pkg_name:find('-', 1, true) + 1)

    local replacement = _symbols.nix .. ' ' .. pkg_name
    if vim.startswith(pkg_name, 'neovim-') then
      replacement = _symbols.neovim
    end
    table.insert(segs, 1, replacement)
    did_abridge = true
  end

  local short_segs = vim
    .iter(segs)
    :enumerate()
    :map(function(i, segment)
      -- don't shorten last segment
      if #segment > seg_max and i < (#segs - 1) then
        return segment:sub(1, seg_max) .. '⋯ ' -- assumes pragmatapro non-mono on ghostty bc it expands the char
      else
        return segment
      end
    end)
    :totable()

  -- we don't want to see /(icon)/, just make it (icon)/
  local prepend_root_slash = not did_abridge

  if opts.return_separated_tail then
    local tail = short_segs[#short_segs]
    -- all segments except for the tail
    local base_segs = vim.list_slice(short_segs, 0, #short_segs - 1)
    return M.path_from_segments(base_segs, prepend_root_slash), tail
  end

  return M.path_from_segments(short_segs, prepend_root_slash)
end

---@param pattern string
function M.purge(pattern)
  for name, _ in pairs(package.loaded) do
    if name:match(pattern) then
      vim.notify('purge: ' .. name, vim.log.levels.DEBUG)
      package.loaded[name] = nil
    end
  end
end

---@param input string
function M.termcodes(input)
  return vim.api.nvim_replace_termcodes(input, true, true, true)
end

---@param codes string
---@param mode? string
function M.send(codes, mode)
  vim.api.nvim_feedkeys(M.termcodes(codes), mode or 'n', false)
end

---@param variable_name string
---@param bufnr number?
function M.is_flag_set(variable_name, bufnr)
  -- global, tab, window
  local set_within_container_or_globally = vim.g[variable_name]
    or vim.t[variable_name]
    or vim.w[variable_name]

  if bufnr then
    -- if a bufnr is passed, only check that buf for the variable (not vim.b)
    return set_within_container_or_globally or vim.b[bufnr][variable_name]
  end

  return set_within_container_or_globally or vim.b[variable_name]
end

return M

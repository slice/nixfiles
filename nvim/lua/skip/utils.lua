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

--- Enforces a maximum length (in codepoints) for a string. All codepoints
--- exceeding the maximum are removed.
---
--- @param max_cps integer The maximum number of codepoints that can be returned.
--- @return string, boolean
function M.trunc_codepoints(text, max_cps)
  -- NOTE (should really be over grapheme clusters but yeah)

  if max_cps <= 0 then
    return '', false
  end

  local cps = vim.str_utfindex(text, 'utf-32')
  if cps <= max_cps then
    return text, false
  end

  local byte_end = vim.str_byteindex(text, 'utf-32', max_cps)
  return text:sub(1, byte_end), true
end

--- @class skip.utils.ShortenOpts
--- @field max_segment_len number?
--- @field return_separated_tail boolean? Whether to return the last path segment separately from the rest.
--- @field ellipses string? What to put at the end of each segment that gets shortened.

--- Shortens an absolute path.
---
--- @param path string
--- @param opts? skip.utils.ShortenOpts
--- @return string|string[]
function M.shorten(path, opts)
  opts = opts or {}
  local seg_max = opts.max_segment_len or 16
  local ellipses = opts.ellipses or '⋯ '
  assert(seg_max > 0)

  local symbolized = path:gsub(vim.pesc(home), '~')
  for _, root in ipairs(M.symbolized_work_roots) do
    symbolized = symbolized:gsub(vim.pesc(root), _symbols.hammer)
  end

  -- initializing it to this is gross but avoids having to do "contains() then
  -- gsub()" in the loop above to find out if we inserted an icon
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
    .iter(ipairs(segs))
    :map(function(i, segment)
      local truncated, did_truncate = M.trunc_codepoints(segment, seg_max)
      local at_last_segment = i == #segs
      if did_truncate and not at_last_segment then
        return truncated .. ellipses
      end

      return segment
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

--- Report a graphical progress bar to Ghostty. See:
--- https://ghostty.org/docs/install/release-notes/1-2-0#graphical-progress-bars
--- @param mode 'remove' | 'running' | 'running_error' | 'indeterminate'
--- @param percent number? A number from 0-100 (when passing "running" or "running_error" as mode).
function M.term_progress(mode, percent)
  if vim.env.TERM_PROGRAM ~= 'ghostty' then
    return
  end

  local status = 1
  if mode == 'remove' then
    status = 0
  elseif mode == 'running_error' then
    status = 2
  elseif mode == 'indeterminate' then
    status = 3
  end

  io.write(('\027]9;4;%s;%s\a'):format(status, percent))
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

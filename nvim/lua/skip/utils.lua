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

function M.form_path_from_segments(sg)
  local joined = table.concat(sg, '/')
  if joined:sub(1, 1) ~= '~' then
    joined = '/' .. joined
  end
  return joined
end

local home = vim.fs.abspath('~')
M.symbolized_roots = { '~/Developer', '~/src' }
--- @param path string
--- @param opts { max_length?: number, return_separated_tail?: boolean }
--- -- @return string|string[]
function M.shorten(path, opts)
  opts = opts or {}
  local max = opts.max_length or 16
  assert(max > 0)
  local symbolized = path:gsub(vim.pesc(home), '~')
  for _, root in ipairs(M.symbolized_roots) do
    symbolized = symbolized:gsub(vim.pesc(root), '*')
  end

  local segs = vim.split(symbolized, '/', { plain = true, trimempty = true })
  local short_segs = vim
    .iter(segs)
    :enumerate()
    :map(function(i, segment)
      -- don't shorten last segment
      if #segment > max and i < (#segs - 1) then
        return segment:sub(1, max) .. '⋯ ' -- assumes pragmatapro non-mono on ghostty bc it expands the char
      else
        return segment
      end
    end)
    :totable()

  if opts.return_separated_tail then
    local tail = short_segs[#short_segs]
    -- all segments except for the tail
    local base_segs = vim.list_slice(short_segs, 0, #short_segs - 1)
    return M.form_path_from_segments(base_segs), tail
  end

  return M.form_path_from_segments(short_segs)
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
function M.flag_set(variable_name, bufnr)
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

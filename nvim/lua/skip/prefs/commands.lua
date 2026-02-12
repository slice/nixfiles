local M = {}

local prefs = require 'skip.prefs'

--- @param input string
--- @return any
function M._parse(input)
  input = vim.trim(input)
  local lowered = string.lower(input)

  if lowered == 'true' or lowered == 't' then
    return true
  elseif lowered == 'false' or lowered == 'f' then
    return false
  elseif input == 'nil' then
    return nil
  end

  local n = tonumber(input, 10)
  if n then
    return n
  end

  return input
end

--- @return { [0]: string, [1]: string? }[]
local function _inspect_chunks(val)
  local hl = 'Normal'
  local typ = type(val)
  if typ == 'boolean' then
    hl = '@boolean'
  elseif typ == 'number' then
    hl = '@number'
  end

  return {
    { vim.inspect(val), hl },
    { (' (%s)'):format(type(val)), 'Delimiter' },
  }
end

function M.setup()
  vim.api.nvim_create_user_command('Pref', function(ctx)
    local fargs = ctx.fargs
    local key = fargs[1]

    if #fargs == 1 then
      -- :Pref format_on_save
      local val = prefs[key]

      -- "format_on_save => true (boolean)"
      vim.api.nvim_echo({
        { key, 'Keyword' },
        { ' => ', 'Delimiter' },
        unpack(_inspect_chunks(val)),
      }, true, {})
    else
      -- :Pref format_on_save true
      local new_val = M._parse(fargs[2])
      require 'skip.prefs.overrides'[key] = new_val

      -- "setting format_on_save => true (boolean)"
      vim.api.nvim_echo({
        { 'setting ', 'MoreMsg' },
        { key, 'Keyword' },
        { ' => ', 'Delimiter' },
        unpack(_inspect_chunks(new_val)),
      }, true, {})
    end
  end, {
    desc = 'Set or view a preference',
    nargs = '*',
    complete = function(lead, cmdline, pos)
      if vim.trim(cmdline) ~= 'Pref' then
        return
      end
      return prefs._pref_keys
    end,
    force = true,
  })
end

return M

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

return M

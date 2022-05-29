local tweaks = {
  bubblegum2 = {
    'link MatchParen LineNr',
    'link TelescopeMatching IncSearch',
    'link TelescopeSelection Pmenu',
    'IndentBlanklineChar guifg=#3d3d3d',
    'Delimiter guifg=#b2b2b2',
    'ColorColumn guibg=#2b2b2b',
    'link Sneak DiffChange',
    'link DiagnosticError Special',
    'link DiagnosticWarn Number',
    'link DiagnosticHint Keyword',
    'Comment gui=italic',
    'link LspCodeLens StatusLineNC',
    'link TelescopeSelection Search',
  },
  zenburn = {
    'link TelescopeMatching ErrorMsg',
    'link DiagnosticWarn Repeat',
    'link DiagnosticError Error',
    'link DiagnosticInfo Number',
  },
  melange = {
    'LineNr guifg=#70645b',
    'link LspCodeLens Folded',
  },
  seoul256 = {
    'link LspCodeLens SpecialKey',
    'link DiagnosticError Error',
    'link DiagnosticWarn Question',
    'link DiagnosticHint Float',
    'link DiagnosticInfo Conditional',
    'CmpItemKindDefault guifg=#a97070',
  },
}

local colorscheme_tweaks_group = vim.api.nvim_create_augroup('skip_colorscheme_tweaks', {})
for colorscheme, tweaks in pairs(tweaks) do
  for _, tweak in ipairs(tweaks) do
    vim.api.nvim_create_autocmd(
      'ColorScheme',
      { group = colorscheme_tweaks_group, pattern = colorscheme, command = 'highlight! ' .. tweak }
    )
  end
end

-- from: https://github.com/wbthomason/dotfiles/blob/5117f6d76c64baa661368e85a25ca463ff858a05/neovim/.config/nvim/lua/config/utils.lua
local function autocommands(group_name, commands)
  if type(commands) == 'string' then
    commands = { commands }
  end

  local group_id = vim.api.nvim_create_augroup(group_name, {})

  for _, command in ipairs(commands) do
    command[2].group = group_id
    vim.api.nvim_create_autocmd(unpack(command))
  end
end

autocommands('skip_hacks', {
  -- <C-x> opens splits in telescope, so we need this to be unmapped
  { 'VimEnter', { pattern = '*', command = 'silent! iunmap <c-x><c-a>' } },
})

autocommands('skip_filetypes', {
  -- enable spellchecking in git commits, reformat paragraphs as you type
  { 'FileType', { pattern = 'gitcommit', command = 'setlocal spell formatoptions=tan | normal ] ' } },
})

autocommands('skip_yanking', {
  { 'TextYankPost', { pattern = '*', command = 'silent! lua vim.highlight.on_yank()' } },
})

local lang_indent_settings = {
  go = { width = 4, with = 'tabs' },
  scss = { width = 2, with = 'spaces' },
  sass = { width = 2, with = 'spaces' },
  cabal = { width = 4, with = 'spaces' },
}

local indentation_tweaks_group = vim.api.nvim_create_augroup('skip_indentation_tweaks', {})
for extension, settings in pairs(lang_indent_settings) do
  local width = settings['width']

  local expandtab = 'expandtab'
  if settings['with'] == 'tabs' then
    expandtab = 'noexpandtab'
  end

  vim.api.nvim_create_autocmd('FileType', {
    group = indentation_tweaks_group,
    pattern = extension,
    command = string.format('setlocal tabstop=%d softtabstop=%d shiftwidth=%d %s', width, width, width, expandtab),
  })
end
vim.api.nvim_create_autocmd(
  { 'BufNewFile', 'BufReadPre' },
  { group = indentation_tweaks_group, pattern = '*.sc,*.sbt', command = 'setfiletype scala' }
)

-- hide line numbers in terminals
autocommands('skip_terminal_numbers', {
  { 'TermOpen', { pattern = '*', command = 'setlocal nonumber norelativenumber' } },
})

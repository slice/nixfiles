local function hi(cmd)
  return 'highlight!' .. cmd
end
local function link(cmd)
  return 'highlight! link ' .. cmd
end

vim.cmd([[highlight default link InlayHint Comment]])
vim.cmd([[highlight default link RustToolsInlayHint InlayHint]])

local mini_tweaks = {
  hi('Comment gui=italic'),
  hi('DiagnosticHint guifg=#70a1cd guibg=#254258'),
  hi('DiagnosticWarn guifg=#cdbe70 guibg=#3d3928'),
  hi('DiagnosticError guifg=#cd7073 guibg=#3d2828'),
  hi('DiagnosticUnderlineError gui=undercurl guisp=#cd7073'),
  hi('DiagnosticSignError guifg=#cd7073 guibg=#324747'),
  hi('SpellBad guifg=#ed9597 gui=underline'),
}

local tweaks = {
  bubblegum2 = {
    link('MatchParen LineNr'),
    link('TelescopeMatching IncSearch'),
    link('TelescopeSelection Pmenu'),
    hi('IndentBlanklineChar guifg=#3d3d3d'),
    hi('Delimiter guifg=#b2b2b2'),
    hi('ColorColumn guibg=#2b2b2b'),
    link('Sneak DiffChange'),
    link('DiagnosticError Special'),
    link('DiagnosticWarn Number'),
    link('DiagnosticHint Keyword'),
    hi('Comment gui=italic'),
    link('LspCodeLens StatusLineNC'),
    link('TelescopeSelection Search'),
  },
  zenburn = {
    link('TelescopeMatching ErrorMsg'),
    link('DiagnosticWarn Repeat'),
    link('DiagnosticError Error'),
    link('DiagnosticInfo Number'),
  },
  melange = {
    hi('LineNr guifg=#70645b'),
    link('LspCodeLens Folded'),
  },
  seoul256 = {
    link('LspCodeLens SpecialKey'),
    link('DiagnosticError Error'),
    link('DiagnosticWarn Question'),
    link('DiagnosticHint Float'),
    link('DiagnosticInfo Conditional'),
    hi('CmpItemKindDefault guifg=#a97070'),
    hi('Comment gui=italic'),
    hi('WinSeparator guifg=#656565 guibg=#333233'),
    hi('SpellBad guifg=#d9d9d9 guibg=#730b00 gui=underline'),
  },
  everforest = {
    hi('TelescopeSelection guibg=#506168'),
    hi('SpellBad gui=underline guibg=#402b2b'),
    'let g:terminal_color_0 = "#67767e"',
    'let g:terminal_color_8 = "#67767e"',
  },
  minicyan = vim.tbl_flatten({
    mini_tweaks,
    {
      hi('InlayHint guifg=#467374'),
      hi('LspCodeLens guibg=#3c6364'),
      -- Most tokens onscreen are going to be `@variable`s, and we don't want to
      -- highlight all of them. It's visually noisy.
      link('@variable.python Normal'),
    },
  }),
  minischeme = vim.tbl_flatten({ mini_tweaks, {} }),
}

local colorscheme_tweaks_group = vim.api.nvim_create_augroup('skip_colorscheme_tweaks', {})
for colorscheme, commands in pairs(tweaks) do
  for _, command in ipairs(commands) do
    vim.api.nvim_create_autocmd(
      'ColorScheme',
      { group = colorscheme_tweaks_group, pattern = colorscheme, command = command }
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
  -- enable spellchecking in git commits
  { 'FileType', { pattern = 'gitcommit', command = 'setlocal spell formatoptions=tn | normal ] ' } },
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

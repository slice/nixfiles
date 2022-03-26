-- from: https://github.com/wbthomason/dotfiles/blob/5117f6d76c64baa661368e85a25ca463ff858a05/neovim/.config/nvim/lua/config/utils.lua
local function aug(group, cmds)
  if type(cmds) == 'string' then
    cmds = { cmds }
  end
  vim.cmd('augroup ' .. group)
  vim.cmd('autocmd!') -- clear existing group
  for _, c in ipairs(cmds) do
    vim.cmd('autocmd ' .. c)
  end
  vim.cmd('augroup END')
end

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
  },
}

vim.cmd([[augroup skip_colorscheme_tweaks]])
vim.cmd([[autocmd!]])
for colorscheme, tweaks in pairs(tweaks) do
  for _, tweak in ipairs(tweaks) do
    vim.cmd('autocmd ColorScheme ' .. colorscheme .. ' highlight! ' .. tweak)
  end
end
vim.cmd([[augroup END]])

-- metals_config = require("metals").bare_config
-- metals_config.settings = {
--   showImplicitArguments = true,
--   showInferredType = true
-- }

-- aug('metals', {
--   'FileType scala,sbt lua require("metals").initialize_or_attach(metals_config)'
--     .. '; setup_lsp_buf()'
-- })

aug('hacks', {
  -- <C-x> opens splits in telescope, so we need this to be unmapped
  'VimEnter * silent! iunmap <c-x><c-a>',
})

aug('completion', {
  -- "BufEnter * lua require'completion'.on_attach()"
  -- 'CompleteDone * if pumvisible() == 0 | pclose | endif'
})

aug('filetypes', {
  -- enable spellchecking in git commits, reformat paragraphs as you type
  'FileType gitcommit setlocal spell formatoptions=tan | normal ] ',
})

-- highlight when yanking (built-in)
aug('yank', 'TextYankPost * silent! lua vim.highlight.on_yank()')

local lang_indent_settings = {
  go = { width = 4, with = 'tabs' },
  scss = { width = 2, with = 'spaces' },
  sass = { width = 2, with = 'spaces' },
  cabal = { width = 4, with = 'spaces' },
}

local language_settings_autocmds = {}
for extension, settings in pairs(lang_indent_settings) do
  local width = settings['width']

  local expandtab = 'expandtab'
  if settings['with'] == 'tabs' then
    expandtab = 'noexpandtab'
  end

  local autocmd = string.format(
    'FileType %s setlocal tabstop=%d softtabstop=%d shiftwidth=%d %s',
    extension,
    width,
    width,
    width,
    expandtab
  )
  table.insert(language_settings_autocmds, autocmd)
end

vim.list_extend(language_settings_autocmds, {
  'BufNewFile,BufReadPre *.sc,*.sbt setfiletype scala',
  -- 'BufNewFile,BufReadPre,BufReadPost *.ts,*.tsx setfiletype typescriptreact',
})

aug('language_settings', language_settings_autocmds)

-- hide line numbers in terminals
aug('terminal_numbers', 'TermOpen * setlocal nonumber norelativenumber')

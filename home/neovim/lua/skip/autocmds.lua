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

-- personal colorscheme tweaks
aug('colorschemes', {
  'ColorScheme bubblegum2'
    .. ' highlight! link MatchParen LineNr'
    .. ' | highlight! link TelescopeMatching IncSearch'
    .. ' | highlight! link TelescopeSelection Pmenu'
    .. ' | highlight! IndentBlanklineChar guifg=#3d3d3d'
    .. ' | highlight! Delimiter guifg=#b2b2b2'
    .. ' | highlight! ColorColumn guibg=#2b2b2b'
    .. ' | highlight! link Sneak DiffChange'
    .. ' | highlight! link DiagnosticError Special'
    .. ' | highlight! link DiagnosticWarn Number'
    .. ' | highlight! link DiagnosticHint Keyword'
    .. ' | highlight! Comment gui=italic',
  -- style floating windows legible for popterms; make comments italic
  'ColorScheme landscape' .. ' highlight NormalFloat guifg=#dddddd guibg=#222222' .. ' | highlight Comment guifg=#999999 gui=italic',
  'ColorScheme zenburn' .. ' highlight! link TelescopeMatching IncSearch',
  -- 'ColorScheme dogrun'
  --   .. ' highlight IndentBlanklineIndent1 guibg=#303345'
  --   .. ' | highlight IndentBlanklineIndent2 guibg=#303345'
})

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

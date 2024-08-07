local autocmds = require("skip.utils").autocmds

local function hi(cmd)
  return "highlight! " .. cmd
end
local function link(cmd)
  return "highlight! link " .. cmd
end

-- TODO: move all of these colorscheme tweaks into their own files

local moonfly_spelling = {
  hi "SpellBad gui=undercurl guifg=#cb8185 guisp=#cb8185",
  hi "SpellRare gui=undercurl guifg=#a69a53 guisp=#a69a53",
  hi "SpellCap gui=undercurl guifg=#739bd2 guisp=#739bd2",
  link "SpellLocal SpellCap",
}

local mini_tweaks = {
  hi "Comment gui=italic",
  hi "DiagnosticHint guifg=#70a1cd guibg=#254258",
  hi "DiagnosticWarn guifg=#cdbe70 guibg=#3d3928",
  hi "DiagnosticError guifg=#cd7073 guibg=#3d2828",
  hi "DiagnosticUnderlineError gui=undercurl guisp=#cd7073",
  hi "DiagnosticSignError guifg=#cd7073 guibg=#324747",
}

local tweaks = {
  ["*"] = {
    link "TelescopeNormal NormalFloat",
    link "PopTermLabel TabLineSel",
    link "@type.builtin Special",
    -- fix underlines in telescope's preview having the wrong color
    link "@markup.link.vimdoc Constant",
    -- pls
    link "@string String",
    link "@boolean Boolean",
    link "@operator Operator",
    link "@markup.raw.vimdoc Comment",
    link "@markup.link.vimdoc String",
    link "MiniDiffSignAdd Added",
    link "MiniDiffSignChange Changed",
    link "MiniDiffSignDelete Removed",
  },
  apparition = {
    hi "@variable guifg=fg",
    hi "@punctuation guifg=NONE",
    hi "@constructor.lua guifg=NONE",
    hi "TelescopeMatching guifg=#000000 guibg=#96bade gui=bold",
    link "DiagnosticInfo Statement",
    link "DiagnosticHint Statement", -- make diff from info?
    link "DiagnosticError ErrorMsg",
    link "DiagnosticWarn WarningMsg",
    hi "CursorLine guibg=#4e1012",
    hi "CursorLineNr guibg=#842024 gui=bold guifg=#ffc8c3",
    hi "SignColumn guibg=NONE",
    hi "ColorColumn guibg=#1d1d1d",
    link "MiniIndentscopeSymbol NonText",
    link "Directory PreProc",
    hi "WinSeparator guibg=NONE",
  },
  bubblegum2 = {
    link "MatchParen LineNr",
    link "TelescopeMatching IncSearch",
    link "TelescopeSelection Pmenu",
    hi "IndentBlanklineChar guifg=#3d3d3d",
    hi "Delimiter guifg=#b2b2b2",
    hi "ColorColumn guibg=#2b2b2b",
    link "Sneak DiffChange",
    link "DiagnosticError Special",
    link "DiagnosticWarn Number",
    link "DiagnosticHint Keyword",
    hi "Comment gui=italic",
    link "LspCodeLens StatusLineNC",
    link "TelescopeSelection Search",
  },
  zenburn = {
    hi "TelescopeMatching gui=bold guifg=#ffffe0 guibg=#284f28",
    link "TelescopeSelectionCaret TelescopeMatching",
    link "DiagnosticWarn Repeat",
    link "DiagnosticError Error",
    link "DiagnosticInfo Number",
    link "diffRemoved DiffText",
    link "diffAdded DiffAdd",
    hi "Error guifg=#e37170 guibg=#3d3535",
    hi "DiagnosticUnderlineError gui=undercurl",
    hi "DiagnosticUnderlineWarn gui=undercurl",
    hi "CursorLine guibg=#4a2724",
    hi "StatusLine gui=bold",
    hi "CursorLineNr gui=bold",
    hi "clear @variable",
    hi "clear Label", -- underline color is wrong in telescope??
  },
  melange = {
    hi "LineNr guifg=#70645b",
    link "LspCodeLens Folded",
  },
  seoul256 = {
    link "LspCodeLens SpecialKey",
    link "DiagnosticError Error",
    link "DiagnosticWarn Question",
    link "DiagnosticHint Float",
    link "DiagnosticInfo Conditional",
    hi "CursorLine guibg=#4a2724",
    hi "CmpItemKindDefault guifg=#a97070",
    hi "TelescopeSelection gui=bold guibg=#007173",
    hi "DiffText guibg=#006978",
    hi "DiffAdd guibg=#366c2d",
    hi "DiffChange guibg=#1a525a",
    hi "LspInlayHint gui=italic guifg=#808080",
    hi "Comment gui=italic",
    hi "WinSeparator guifg=#656565 guibg=#333233",
    hi "SpellBad guifg=#d9d9d9 guibg=#4f3333 gui=underline",
    link "TelescopeBorder WinSeparator",
    -- needed for tint.nvim
    link "NormalNC Normal",
    -- seoul256 relies on these being implicitly set (which is true in vanilla
    -- vim, but not in nvim)
    hi "StatusLine gui=reverse,bold",
    hi "StatusLineNC gui=reverse",
    hi "TabLineFill guibg=#333233",
  },
  everforest = {
    hi "TelescopeSelection guibg=#506168",
    hi "SpellBad gui=underline guibg=#402b2b",
    'let g:terminal_color_0 = "#67767e"',
    'let g:terminal_color_8 = "#67767e"',
  },
  minicyan = vim
    .iter({
      mini_tweaks,
      -- moonfly_spelling,
      {
        hi "LspInlayHint guifg=#467374",
        hi "LspCodeLens guibg=#3c6364",
        -- Most tokens onscreen are going to be `@variable`s, and we don't want to
        -- highlight all of them. It's visually noisy.
        link "@variable.python Normal",

        hi "CursorLine guibg=#341d1b",
        hi "CursorLineNr guibg=#c42124 guifg=#3d0305",

        hi "StatusLine gui=reverse,bold",
        hi "SpellBad guifg=NONE gui=undercurl",
      },
    })
    :flatten()
    :totable(),
  minischeme = vim.iter({ mini_tweaks, moonfly_spelling }):flatten():totable(),
  moonfly = moonfly_spelling,
  ["tokyonight"] = {
    hi "StatusLine gui=reverse,bold",
    hi "TermCursor guibg=#c22125 guifg=#000000 gui=NONE",
    hi "TermCursorNC gui=reverse",
    link "DiagnosticUnnecessary Comment",
  },
  neobones = {
    hi "TabLineSel gui=reverse,bold",
    hi "TabLine guifg=#c6d5cf guibg=#20303a",
    hi "StatusLine gui=reverse,bold",
    hi "SpellBad guifg=NONE gui=undercurl",
  },
  default = { -- <3
    link "NormalNC Normal",
    hi "StatusLine gui=reverse,bold",
    hi "TabLine guifg=NvimLightGrey3 guibg=NvimDarkGrey1",
    hi "TabLineSel gui=bold,reverse",

    link "LspInlayHint Comment",
    hi "DiagnosticUnderlineError gui=undercurl",
    hi "DiagnosticUnderlineWarn gui=undercurl",

    -- fugitive:
    hi "fugitiveStagedModifier guifg=NvimLightGreen",
    hi "fugitiveUnstagedModifier guifg=NvimLightRed",
    link "fugitiveUntrackedModifier Comment",
    link "fugitiveUnstagedHeading Identifier",
    link "fugitiveStagedHeading Identifier",
    hi "fugitiveCount gui=bold",
    link "diffRemoved DiffDelete",
    link "diffAdded DiffAdd",
  },
}

do
  local group = vim.api.nvim_create_augroup("SkipColorschemeTweaks", {})

  for colorscheme, mods in pairs(tweaks) do
    local autocmd = {
      group = group,
      pattern = colorscheme,
      desc = "skip colorscheme tweaks",
    }

    if type(mods) == "function" then
      autocmd["callback"] = mods
    else
      if mods["run"] ~= nil then
        autocmd["callback"] = function()
          mods["run"]()
          mods["run"] = nil
          vim.cmd(table.concat(mods, " | "))
        end
      else
        autocmd["command"] = table.concat(mods, " | ")
      end
    end

    vim.api.nvim_create_autocmd("ColorScheme", autocmd)
  end
end

autocmds("SkipHacks", {
  -- <C-x> opens splits in telescope, so we need this to be unmapped
  {
    "VimEnter",
    { pattern = "*", command = "silent! iunmap <c-x><c-a>", desc = "Unmaps <c-x><c->a for Telescope" },
  },
})

autocmds("SkipFiletypes", {
  -- enable spellchecking in git commits
  { "FileType", { pattern = "gitcommit", command = "setlocal spell formatoptions=tn | normal ] " } },
  { "FileType", { pattern = "typescript", command = "setlocal commentstring=//\\ %s" } },
  { "FileType", { pattern = "dirvish,man,text,git,gitignore", command = "setlocal nospell" } },
  -- swift interpolations look like "\(...)", and we want text objects and
  -- motions involving parens to not think they're escaped
  { "FileType", { pattern = "swift", command = "setl cpo+=M" } },
  { "BufReadPost", { pattern = "*.md,*.mdx", command = "setlocal spell | setf markdown" } },
  { { "BufNewFile", "BufReadPre" }, { pattern = "*.sc,*.sbt", command = "setfiletype scala" } },
})

autocmds("SkipYanking", {
  { "TextYankPost", { pattern = "*", command = "silent! lua vim.highlight.on_yank()" } },
})

local lang_indent_settings = {
  go = { width = 4, with = "tabs" },
  scss = { width = 2, with = "spaces" },
  sass = { width = 2, with = "spaces" },
  cabal = { width = 4, with = "spaces" },
  fluent = { width = 2, with = "spaces" },
  rust = { width = 4, with = "spaces" },
}

local indentation_tweaks_group = vim.api.nvim_create_augroup("SkipIndentationTweaks", {})
for extension, settings in pairs(lang_indent_settings) do
  local width = settings["width"]

  local expandtab = "expandtab"
  if settings["with"] == "tabs" then
    expandtab = "noexpandtab"
  end

  vim.api.nvim_create_autocmd("FileType", {
    group = indentation_tweaks_group,
    pattern = extension,
    command = string.format("setlocal tabstop=%d softtabstop=%d shiftwidth=%d %s", width, width, width, expandtab),
  })
end

autocmds("SkipHelp", {
  { "FileType", { pattern = "help", command = "setlocal signcolumn=no" } },
})

-- for stopping LSPs - we can't do it inside of tree-sitter highlight.disable
-- because that's after LSPs ._.
autocmds("SkipHugeFiles", {
  {
    "BufReadPre",
    {
      pattern = "*",
      callback = function(args)
        local bufnr = args.buf
        local file = args.file
        if not bufnr or not file then
          return
        end

        local huge = require("skip.huge")

        if vim.fn.getfsize(file) > huge.limits.max_file_size_bytes then
          huge.bounce(bufnr, "too many bytes before reading")
        end
      end,
    },
  },
})

autocmds("SkipTerminal", {
  { "TermOpen", { pattern = "*", command = "setlocal nonumber norelativenumber nospell" } },
})

autocmds("SkipLocalCursorline", {
  { { "BufWinEnter", "WinEnter" }, { pattern = "*", command = "setlocal cursorline" } },
  { "WinLeave", { pattern = "*", command = "setlocal nocursorline" } },
})

autocmds("SkipParentDirectoryCreation", {
  {
    { "BufWritePre", "FileWritePre" },
    {
      pattern = "*",
      callback = function()
        if vim.api.nvim_buf_get_name(0):find "://" then
          return
        end
        vim.fn.mkdir(vim.fn.expand "<afile>:p:h", "p")
      end,
      desc = "Automatically create parent directories when saving",
    },
  },
})

autocmds("SkipTelescopeCursorLine", {
  {
    -- this should really be BufEnter or something, but it doesn't work :(
    "InsertEnter",
    {
      pattern = "*",
      callback = function()
        if vim.bo.filetype == "TelescopePrompt" then
          vim.wo.cursorline = false
        end
      end,
      desc = "Automatically disable cursorline inside of Telescope",
    },
  },
})

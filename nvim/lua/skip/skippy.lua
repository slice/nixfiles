local lush = require("lush")
local hsl = lush.hsl

local base = hsl("#061022")
local tan = hsl("#dbcaa5")
local blue = tan.hue(214).sa(30)
local offwhite_blue = hsl("#cbd2e2").da(2)
local deep_lilac = hsl("#a352af").de(20)
local medium_purple = hsl("#856fda")
local warm = medium_purple.de(90).li(30)
local highlighter = hsl("#d6eca6")
local rose = hsl("#af5169")
local neon = hsl("#a5f88c")
local forest = deep_lilac.hue(138)
local bronze = hsl("#6b5300") -- literally just NvimDarkYellow
local skyblue = hsl("#a6dbfe")
local urgent = hsl("#c7172c")

---@diagnostic disable: undefined-global
---@format disable-next
local spec = lush(function(injected_functions)
  local sym = injected_functions.sym

  local function bg_2() return Normal.bg.li(15) end
  local function bg_3() return Normal.bg.li(20) end
  local function bg_fg() return Normal.bg.li(35).de(30) end
  local function frozen() return Normal.bg.li(10).de(30) end
  local function chalk() return Normal.fg.li(40) end

  return {
    Normal { bg = base, fg = warm },
    -- NormalNC { bg = frozen(), fg = frozen().li(60) },
    NormalNC { Normal }, -- needed for tint.nvim
    NormalFloat { Normal },

    Visual { bg = bg_3() },

    LineNr { fg = bg_fg() },
    LineNrAbove { fg = bg_fg().mix(hsl("#ff0000"), 15) },
    LineNrBelow { fg = bg_fg().mix(hsl("#00ff00"), 7) },
    NonText { LineNr },
    SpecialKey { LineNr },
    SignColumn { LineNr },
    CursorLine { bg = urgent.da(50) },
    CursorLineNr { CursorLine, bold = true },
    CursorLineSign { CursorLineNr },
    ColorColumn { bg = Normal.bg.li(5) },
    Folded { bg = bg_3(), italic = true },

    WinSeparator { fg = bg_3() },
    StatusLine { fg = chalk(), bg = urgent.da(10), bold = true },
    StatusLineNC { Normal, bg = bg_3() },
    StatusLineTerm { fg = "black", bg = StatusLine.bg.hue(140).li(10), bold = true },
    StatusLineTermNC { StatusLineTerm, bg = StatusLineTerm.bg.da(60) },

    -- comment
    Comment { bg = Normal.bg.li(10), fg = Normal.fg.hue(Normal.bg.h).da(30).sa(20), italic = true },
    MiniHipatternsNote { fg = skyblue, bold = true },
    MiniHipatternsFixme { MiniHipatternsNote },
    MiniHipatternsTodo { MiniHipatternsNote },
    MiniHipatternsHack { MiniHipatternsNote },

    -- indent lines
    MiniIndentscopeSymbol { fg = bg_fg() },

    ModeMsg { fg = "white", bg = urgent, bold = true },
    MoreMsg { fg = forest, bold = true },
    Question { MoreMsg },
    QuickFixLine { MoreMsg },

    TabLine { StatusLineNC },
    TabLineFill { TabLine },
    TabLineSel { StatusLine },

    Search { fg = bronze.de(70).li(60), bg = bronze, underline = true },
    IncSearch { Search },
    CurSearch { Search, gui = "reverse,bold" },

    -- actual thingies
    sym"@keyword" { fg = deep_lilac, bold = true },
    sym"@attribute" { sym"@keyword", gui = "" },

    -- resets
    sym"@variable" {},
    Type {},
    Function {},
    Constant {},
    Identifier {},
    Statement {},
    sym"@constructor" {},

    -- `null`, `undefined`, `this`
    Special { fg = Normal.fg.mix(sym("@keyword").fg, 60) },
    sym"@variable.builtin" {}, -- because it doesn't catch _every_ built-in so it's not consistent >:(
    sym"@skp.this" { Special },
    sym"@skp.var_decl_keyword" { gui = "NONE,nocombine" },

    Number { fg = highlighter },
    Boolean { Number },

    -- imports, includes, macros, conditional compilation, defines, etc.
    sym"@keyword.import" { fg = sym("@keyword").fg.hue(0), bold = true },
    Include { sym"@keyword.import" },
    Macro { sym"@keyword.import" },
    Precondit { sym"@keyword.import" },
    Define { sym"@keyword.import" },

    -- `while`/`for`/`continue`
    sym"@keyword.repeat" { fg = forest, bold = true },
    Repeat { sym"@keyword.repeat" },
    -- `return`/`break`
    sym"@keyword.return" { fg = forest, gui = "underdotted,bold", sp = forest.li(30) },
    sym"@skp.break" { sym"@keyword.return" },

    -- `try`/`catch`/`finally`
    sym"@keyword.exception" { fg = rose, bg = rose.da(60), bold = true },
    Exception { sym"@keyword.exception" },

    -- `if`/`switch`/`case`/ternary
    sym"@keyword.conditional" { fg = rose, bold = true },
    Conditional { sym"@keyword.conditional" },

    -- `async`/`await`
    sym"@keyword.coroutine" { fg = rose.hue(250).li(20), gui = "bold,italic" },

    TelescopeSelection { gui = "bold,reverse" },
    TelescopeMatching { bg = bg_3(), bold = true },

    -- things that are slightly brighter (e.g. object keys)
    sym"@lsp.typemod.property.declaration" { fg = chalk() },
    Title { fg = chalk(), bold = true },

    -- types
    sym"@skp.type_like_actually" { fg = blue.de(40).da(30) },
    Directory { sym"@skp.type_like_actually" },                              -- here for some reason
    sym"@type.builtin.typescript" { fg = (sym"@type").fg, italic = true }, -- ?

    -- strings, characters
    String { fg = blue, italic = true },
    Character { String, gui = "NONE" },

    -- dim punctuation/delimiters
    sym"@punctuation" { fg = Normal.fg.da(35) },
    MatchParen { fg = (sym"@punctuation").fg.li(40), gui = "bold,reverse" },
    Delimiter { sym"@punctuation" }, -- "character that needs attention"?
    sym"@skp.fat_arrow" { sym"@punctuation" },

    Operator { bold = true },

    -- function/method decls
    -- sym"@lsp.typemod.function.declaration" { fg = neon, bg = neon.da(80), bold = true },
    sym"@skp.major_decl" { fg = neon.li(10).de(20), bg = neon.da(90), bold = true },
    -- sym"@function.method.call" {},
    -- sym"@lsp.type.method.lua" {},

    -- class decls
    sym"@lsp.typemod.class.declaration" { fg = neon.hue(20), bg = neon.hue(20).da(80), bold = true },
    sym"@skp.constructor" { fg = neon.hue(20), bold = true },

    -- {j,t}sx, (x)(ht)ml
    sym"@tag" { fg = forest.li(20).de(30) },
    sym"@tag.delimiter" { fg = (sym"@tag").fg.da(40) },
    sym"@tag.attribute" { fg = (sym"@tag").fg.li(20) },
    sym"@skp.tag.opening" { sym"@tag", bold = true },
    sym"@skp.tag.closing" { sym"@tag", bold = true },

    -- React hooks (useState, etc.)
    sym"@skp.hook" { fg = hsl(280, 50, 80) },

    -- popup menu
    Pmenu { Normal, italic = true },
    PmenuSel { Normal, reverse = true, bold = true },
    PmenuKindSel { PmenuSel },
    PmenuExtraSel { PmenuSel },
    PmenuKind { sym"@skp.type_like_actually" },
    PmenuExtra { PmenuKind },

    -- diagnostics
    DiagnosticError { fg = urgent.li(30) },
    DiagnosticUnderlineError { fg = DiagnosticError.fg, gui = "undercurl" },
    ErrorMsg { DiagnosticError, bold = true },
    DiagnosticHint { fg = skyblue },
    DiagnosticUnderlineHint { fg = skyblue, gui = "undercurl" },
    DiagnosticInfo { DiagnosticHint },
    DiagnosticUnderlineInfo { DiagnosticUnderlineHint },
    DiagnosticWarn { fg = highlighter },
    WarningMsg { DiagnosticWarn, bold = true },
    DiagnosticUnderlineWarn { fg = highlighter, gui = "undercurl" },
    DiagnosticUnnecessary { fg = sym"@punctuation".fg, gui = "undercurl" },

    fugitiveUntrackedSection { bg = hsl(0, 100, 10) },
    fugitiveUntrackedHeading { fugitiveUntrackedSection, bold = true },
    fugitiveUntrackedModifier { fugitiveUntrackedSection, bold = true },
    fugitiveUnstagedSection { bg = hsl(50, 100, 15) },
    fugitiveUnstagedHeading { fugitiveUnstagedSection, bold = true },
    fugitiveUnstagedModifier { fugitiveUnstagedSection, bold = true },
    fugitiveStagedSection { bg = hsl(forest.h, 100, 15) },
    fugitiveStagedHeading { fugitiveStagedSection, bold = true },
    fugitiveStagedModifier { fugitiveStagedSection, bold = true },
    fugitiveCount {},

    -- diffs
    Added { fg = forest },
    diffAdded { Added },
    Removed { fg = forest.hue(0), gui = "strikethrough" },
    diffRemoved { Removed },
    Changed { fg = forest.hue(200).li(10) },
    diffChanged { Changed },

    -- vimdoc
    sym"@label.vimdoc" { sym"@keyword" },
    sym"@markup.link.vimdoc" { Special },
    sym"@markup.raw.block.vimdoc" { fg = Normal.fg.da(15) },
    sym"@variable.parameter.vimdoc" { bold = true },

    -- which-key
    sym"WhichKey" { sym"@skp.type_like_actually", bold = true },
    WhichKeySeparator { sym"@punctuation", gui = "NONE" },

    CmpGhostText { fg = CursorLine.bg.li(50).de(40) },
  }
end)

return spec

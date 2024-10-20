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
local spec = lush(function(injected_functions)
  local sym = injected_functions.sym

  local function bg_2() return Normal.bg.li(15) end
  local function bg_3() return Normal.bg.li(20) end
  local function bg_fg() return Normal.bg.li(35).de(50) end
  local function frozen() return Normal.bg.li(10).de(30) end

  return {
    Normal { bg = base, fg = warm },
    NormalNC { bg = frozen(), fg = frozen().li(60) },

    Visual { bg = bg_3() },

    LineNr { fg = bg_fg() },
    LineNrAbove { fg = bg_fg().mix(hsl("#ff0000"), 13) },
    LineNrBelow { fg = bg_fg().mix(hsl("#00ff00"), 8) },
    NonText { LineNr },
    SignColumn { LineNr },
    CursorLine { bg = urgent.da(50) },
    CursorLineNr { CursorLine, gui = "bold" },
    CursorLineSign { CursorLineNr },
    ColorColumn { bg = Normal.bg.li(5) },
    Folded { bg = bg_3() },

    WinSeparator { fg = bg_3() },
    StatusLine { Normal, bg = urgent.da(50), gui = "bold" },
    StatusLineNC { Normal, bg = bg_3() },

    -- comment
    Comment { bg = Normal.bg.li(10), fg = Normal.fg.hue(Normal.bg.h).da(30).sa(20), gui = "italic" },
    MiniHipatternsNote { fg = skyblue, gui = "bold" },
    MiniHipatternsFixme { MiniHipatternsNote },
    MiniHipatternsTodo { MiniHipatternsNote },
    MiniHipatternsHack { MiniHipatternsNote },

    -- indent lines
    MiniIndentscopeSymbol { fg = bg_fg() },

    -- diagnostics
    DiagnosticError { fg = urgent.li(30) },
    DiagnosticUnderlineError { fg = DiagnosticError.fg, gui = "undercurl" },
    ErrorMsg { DiagnosticError },
    DiagnosticHint { fg = skyblue },
    DiagnosticUnderlineHint { fg = skyblue, gui = "undercurl" },
    DiagnosticInfo { DiagnosticHint },
    DiagnosticUnderlineInfo { DiagnosticUnderlineHint },
    DiagnosticWarn { fg = highlighter },
    WarningMsg { DiagnosticWarn },
    DiagnosticUnderlineWarn { fg = highlighter, gui = "undercurl" },
    DiagnosticUnnecessary { gui = "strikethrough" },

    ModeMsg { fg = "white", bg = urgent, gui = "bold" },
    MoreMsg { fg = forest, gui = "bold" },
    Question { MoreMsg },
    QuickFixLine { MoreMsg },

    TabLine { StatusLineNC },
    TabLineFill { TabLine },
    TabLineSel { StatusLine },

    Search { fg = bronze.de(70).li(60), bg = bronze },
    IncSearch { Search },
    CurSearch { Search, gui = "reverse,bold" },

    -- actual thingies
    sym "@keyword" { fg = deep_lilac, gui = "bold" },
    sym "@attribute" { sym "@keyword", gui = "" },

    -- resets
    sym "@variable" {},
    Type {},
    Function {},
    Constant {},
    Identifier {},
    Statement {},

    -- `null`, `undefined`, `this`
    Special { fg = Normal.fg.mix(sym("@keyword").fg, 60) },
    sym "@variable.builtin" {}, -- because it doesn't catch _every_ built-in so it's not consistent >:(
    sym "@skp.this" { Special },
    sym "@skp.var_decl_keyword" { gui = "NONE,nocombine" },

    Number { fg = highlighter, gui = "NONE" },
    Boolean { Number, gui = "bold" },

    -- imports, includes, macros, conditional compilation, defines, etc.
    sym "@keyword.import" { fg = sym("@keyword").fg.hue(0), gui = "bold" },
    Include { sym "@keyword.import" },
    Macro { sym "@keyword.import" },
    Precondit { sym "@keyword.import" },
    Define { sym "@keyword.import" },

    -- `while`/`for`/`continue`
    sym "@keyword.repeat" { fg = forest, gui = "bold" },
    Repeat { sym "@keyword.repeat" },
    -- `return`/`break`
    sym "@keyword.return" { fg = forest, gui = "underdotted,bold", sp = forest },
    sym "@skp.break" { sym "@keyword.return" },

    -- `try`/`catch`/`finally`
    sym "@keyword.exception" { fg = rose, bg = rose.da(60), gui = "bold" },
    Exception { sym "@keyword.exception" },

    -- `if`/`switch`/`case`/ternary
    sym "@keyword.conditional" { fg = rose, gui = "bold" },
    Conditional { sym "@keyword.conditional" },

    -- `async`/`await`
    sym "@keyword.coroutine" { fg = rose.hue(250).li(20), gui = "bold,italic" },

    TelescopeSelection { gui = "bold,reverse" },
    TelescopeMatching { bg = bg_3(), gui = "bold" },
    -- can't really tweak this any further because of NormalNC
    PmenuSel { gui = "reverse,bold" },

    -- object keys are slightly brighter
    sym "@lsp.typemod.property.declaration" { fg = Normal.fg.li(50) },

    -- types
    sym "@skp.type_like_actually" { fg = blue.de(40).da(30) },
    Directory { sym "@skp.type_like_actually" },                              -- here for some reason
    sym "@type.builtin.typescript" { fg = (sym "@type").fg, gui = "italic" }, -- ?

    -- strings, characters
    String { fg = blue, gui = "italic" },
    Character { String, gui = "NONE" },

    -- dim punctuation/delimiters
    sym "@punctuation" { fg = Normal.fg.da(35) },
    MatchParen { fg = (sym "@punctuation").fg.li(40), gui = "bold,reverse" },
    sym "@skp.fat_arrow" { sym "@punctuation" },

    Operator { gui = "bold" },

    -- function/method decls
    -- sym "@lsp.typemod.function.declaration" { fg = neon, bg = neon.da(80), gui = "bold" },
    sym "@skp.major_decl" { fg = neon.li(10).de(20), bg = neon.da(90), gui = "bold" },
    -- sym "@function.method.call" {},
    -- sym "@lsp.type.method.lua" {},

    -- class decls
    sym "@lsp.typemod.class.declaration" { fg = neon.hue(20), bg = neon.hue(20).da(80), gui = "bold" },
    sym "@skp.constructor" { fg = neon.hue(20), gui = "bold" },

    -- {j,t}sx, (x)(ht)ml
    sym "@tag" { fg = forest.li(20).de(30) },
    sym "@tag.delimiter" { fg = (sym "@tag").fg.da(40) },
    sym "@tag.attribute" { fg = (sym "@tag").fg.li(20) },
    sym "@skp.tag.opening" { sym "@tag", gui = "bold" },
    sym "@skp.tag.closing" { sym "@tag", gui = "bold" },

    -- React hooks (useState, etc.)
    sym "@skp.hook" { fg = hsl(280, 50, 80) },

    fugitiveUntrackedSection { bg = hsl(0, 100, 10) },
    fugitiveUntrackedHeading { fugitiveUntrackedSection, gui = "bold" },
    fugitiveUntrackedModifier { fugitiveUntrackedSection, gui = "bold" },
    fugitiveUnstagedSection { bg = hsl(50, 100, 15) },
    fugitiveUnstagedHeading { fugitiveUnstagedSection, gui = "bold" },
    fugitiveUnstagedModifier { fugitiveUnstagedSection, gui = "bold" },
    fugitiveStagedSection { bg = hsl(forest.h, 100, 15) },
    fugitiveStagedHeading { fugitiveStagedSection, gui = "bold" },
    fugitiveStagedModifier { fugitiveStagedSection, gui = "bold" },
    fugitiveCount {},

    -- diffs
    Added { fg = forest },
    diffAdded { Added },
    Removed { fg = forest.hue(0), gui = "strikethrough" },
    diffRemoved { Removed },
    Changed { fg = forest.hue(200).li(10) },
    diffChanged { Changed },
  }
end)

return spec

local g = vim.g

-- avoid loading the autoload portions of netrw so "e ." uses dirvish, but we
-- can still use :GBrowse from fugitive
g.loaded_netrwPlugin = true

-- colorschemes
g.seoul256_background = 236
g.zenburn_old_Visual = true
g.zenburn_alternate_Visual = true
g.zenburn_italic_Comment = true
g.zenburn_subdued_LineNr = true
g.nightflyCursorColor = true
g.nightflyUndercurls = false
g.nightflyItalics = false
g.moonflyCursorColor = true
g.moonflyUndercurls = false
g.moonflyItalics = true

g.rooter_patterns = { '.git' }
g.rooter_manual_only = true
g.rooter_cd_cmd = 'tcd'

-- TODO: move everything to which-key, i think, but that can't live in this
-- exact file bc it needs to load first. maybe export them as modules :3c
-- general keybindings can be a massive nested table??

local utils = require("skip.utils")
local map = vim.keymap.set

-- after 6? 7? years of typing <ESC>:w<CR>, it's time for somethin' different
map("n", "<Leader>s", "<cmd>w<CR>")
map("n", "<Leader>w", "<cmd>noautocmd w<CR>")

map("n", "<Leader>ji", "<Cmd>Inspect<CR>")

-- pressing <S-Space> in a terminal used to input <Space>, but it doesn't
-- anymore! sometimes i don't release shift before pressing space, so this is
-- useful
--
-- update(2023-12-18): doesn't seem to be necessary anymore with CSI u?
map("t", "<S-Space>", "<Space>")
map("t", "<Esc>", "<C-\\><C-n>")

map("!", "<C-j>", function()
  if vim.api.nvim_get_mode().mode == "c" then
    utils.send [[<C-R><C-R>+]]
  else
    ---@diagnostic disable-next-line: redundant-parameter
    local clipboard_lines = vim.fn.getreg("+", 1, true) --[=[@as string[]]=]
    vim.api.nvim_put(clipboard_lines, "c", false, true)
  end
end, { desc = "Charwise paste from clipboard register" })

-- jump around windows easier. this is probably breaking something?
map("n", "<C-H>", "<C-W><C-H>")
map("n", "<C-J>", "<C-W><C-J>")
map("n", "<C-K>", "<C-W><C-K>")
map("n", "<C-L>", "<C-W><C-L>")

map({ "i", "n" }, "<C-;>", "<cmd>nohlsearch<CR>")

-- nvim-popterm.lua
map({ "t", "n" }, "<A-Tab>", function()
  ---@diagnostic disable-next-line: undefined-global
  if IS_POPTERM == nil then
    return
  end

  ---@diagnostic disable-next-line: undefined-global
  if IS_POPTERM() then
    ---@diagnostic disable-next-line: undefined-global
    POPTERM_HIDE()
  else
    ---@diagnostic disable-next-line: undefined-global
    POPTERM_NEXT()
  end
end)

-- quickly open :terminals
map("n", "<Leader>te", "<cmd>tabnew +terminal<CR>")
map("n", "<Leader>ts", "<cmd>below split +terminal<CR>")
map("n", "<Leader>tv", "<cmd>vsplit +terminal<CR>")

-- diagnostics
map({ "v", "n" }, "[D", function()
  local diagnostic = vim.diagnostic.get_prev({ severity = vim.diagnostic.severity.ERROR })
  if not diagnostic then
    vim.notify("no prev error found")
    return
  end
  vim.diagnostic.jump({ diagnostic = diagnostic })
end, { desc = "Previous error diagnostic" })
map({ "v", "n" }, "]D", function()
  local diagnostic = vim.diagnostic.get_next({ severity = vim.diagnostic.severity.ERROR })
  if not diagnostic then
    vim.notify("no next error found")
    return
  end
  vim.diagnostic.jump({ diagnostic = diagnostic })
end, { desc = "Next error diagnostic"})

-- vimrc; https://learnvimscriptthehardway.stevelosh.com/chapters/08.html
map("n", "<Leader>vs", "<cmd>vsplit | terminal hm-switch<CR>")

-- replace :bdelete with sayonara
-- map("c", "bd", "Sayonara!")

-- if we're using "CSI u" (a specification for accurate key reporting in
-- terminals) or otherwise correctly recognize these key presses, let
-- opt+left/right navigate between words in command-line mode
map("!", "<M-Left>", "<S-Left>")
map("!", "<M-Right>", "<S-Right>")

do
  -- sometimes i hold down shift for too long ;_;
  local command_aliases = {
    W = "w",
    Wq = "wq",
    WQ = "WQ",
    Wqa = "wqa",
    Q = "q",
    Qa = "qa",
    Bd = "bd",
    E = "e",
  }

  for lhs, rhs in pairs(command_aliases) do
    vim.cmd(string.format("command! -nargs=* -bang %s %s<bang> <args>", lhs, rhs))
  end
end

-- maps so we can use :diffput and :diffget in visual mode
-- (can't use d because it means delete)
map("v", "fp", ":'<,'>diffput<CR>")
map("v", "fo", ":'<,'>diffget<CR>")

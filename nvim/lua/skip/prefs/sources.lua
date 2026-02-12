--- @type skip.PrefSource[]
local M = {
  {
    name = 'defaults',
    prefs = require 'skip.prefs.defaults',
  },
  require 'skip.prefs.file'.source,
  {
    name = 'session-wide overrides (via :Pref)',
    prefs = require 'skip.prefs.overrides',
  },
}

return M

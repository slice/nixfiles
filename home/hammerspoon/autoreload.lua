local M = {}

local home = os.getenv('HOME')

function M.watcher_callback(files)
  needs_reload = false
  for _, file in pairs(files) do
    if file:sub(-4) == '.lua' then
      needs_reload = true
    end
  end
  if needs_reload then
    print([[automatically reloading]])
    hs.reload()
  end
end

M.watcher = hs.pathwatcher.new(home .. '/.hammerspoon/', M.watcher_callback):start()

return M

local apps = {
  'Kitty',
  hs.application.defaultAppForUTI('public.html'), -- web browser
  'Discord Canary',
  f = 'Finder',
}

for key, app_name in pairs(apps) do
  hs.hotkey.bind({ 'alt' }, tostring(key), function()
    if not hs.application.launchOrFocus(app_name) then
      hs.application.launchOrFocusByBundleID(app_name)
    end
  end)
end

hs.hotkey.bind({ 'cmd', 'shift' }, '0', function()
  local win = hs.window.focusedWindow()
  if win:frame() == win:screen():frame() or not win:isMaximizable() then
    local screen = win:screen():frame()

    local width = screen.w * 0.5
    local height = screen.h * 0.8
    win:setFrame(hs.geometry((screen.w - width) / 2, (screen.h - height) / 2, width, height))
  else
    win:maximize()
  end
end)

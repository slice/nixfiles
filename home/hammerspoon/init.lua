-- vi: foldmethod=marker

require('./windowing')
autoeq = require('./autoeq')
autoreload = require('./autoreload')

hs.hotkey.bind({ 'cmd', 'alt', 'ctrl' }, 'R', function()
  hs.reload()
end)

hs.hotkey.bind({ 'cmd', 'alt', 'ctrl' }, 'A', function()
  autoeq.engage()
end)

function appwatcher_callback(app_name, event_type, app)
  if event_type == hs.application.watcher.activated then
    print('app activated:', app_name)
  end
end

application_watcher = hs.application.watcher.new(appwatcher_callback)
application_watcher:start()

hs.alert.show('hammerspoon says hi', autoeq.alert_style)

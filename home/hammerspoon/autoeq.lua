-- vi: foldmethod=marker

local M = {}

-- don't automatically engage when there has been no HID events for this many seconds
M.autoengage_idle_timeout = 4
-- automatically disengage when ditto
M.autodisengage_idle_timeout = 10

M.alert_style = {
  textSize = 28,
  radius = 10,
  strokeColor = { white = 1, alpha = 0.25 },
  fillColor = { white = 0, alpha = 0.25 },
  textColor = { white = 1, alpha = 0.75 },
}

local function hid_idle_time()
  output = hs.execute([[ioreg -r -c IOHIDSystem | awk '/HIDIdleTime/ { print $NF / 1000000000; exit; }']])
  return tonumber(output)
end

function M.audiohijack_session(session_name)
  local session = { name = session_name }
  setmetatable(session, {
    __index = function(table, key)
      -- XXX: always return a method that calls the correspondingly named javascript method on the session
      return function(...)
        local code = ([[app.sessionWithName('%s').%s();]]):format(table['name'], key)
        local shell = ([[echo "%s" | shortcuts run "Script Audio Hijack"]]):format(code)
        print('shelling out:', shell)
        hs.execute(shell)
      end
    end,
  })
  return session
end

local hd650 = M.audiohijack_session('Sennheiser HD650 EQ')
local airpods = M.audiohijack_session('AirPods Pro 2')

M.profiles = {
  -- ['AirPods Pro'] = { name = 'airpods', on = airpods.start, off = airpods.stop },
  ['External Headphones'] = {
    name = 'hd650',
    on = hd650.start,
    off = hd650.stop,
  },
}

M.active_profile = nil

function M.disengage()
  if M.active_profile ~= nil then
    M.profiles[M.active_profile]['off']()
    M.active_profile = nil
  end
end

function M.engage()
  local output = hs.audiodevice.defaultOutputDevice()
  if output == nil then
    return
  end
  local name = output:name()

  M.disengage()

  for substring, profile in pairs(M.profiles) do
    if name:find(substring) then
      hs.alert.show(('autoeq (%s)'):format(profile['name']), M.alert_style, nil, 3)
      profile['on']()
      M.active_profile = substring
      break
    end
  end
end

if false then
  -- audiodevice watcher {{{

  hs.audiodevice.watcher.setCallback(function(event)
    if hid_idle_time() > M.autoengage_idle_timeout then
      print(('NOT engaging autoeq upon audio device change, idle threshold exceeded (event: %s)'):format(event))
      return
    end

    if event == 'dOut' then
      M.engage()
    end
  end)

  if not hs.audiodevice.watcher.isRunning() then
    hs.audiodevice.watcher.start()
  end

  -- }}}

  -- autodisengage timer {{{

  M.autodisengage_timer = hs.timer
    .new(1, function()
      if hid_idle_time() > M.autodisengage_idle_timeout and M.active_profile ~= nil then
        print('automatically disengaging autoeq, user is idle')
        M.disengage()
      end
    end)
    :start()

  -- }}}
end

return M

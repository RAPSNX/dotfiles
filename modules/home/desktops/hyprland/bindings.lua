local function bind(keys, dispatcher, description, options)
  options = options or {}
  options.description = description
  hl.bind(keys, dispatcher, options)
end

local function sequence(...)
  local dispatchers = { ... }
  return function()
    for _, dispatcher in ipairs(dispatchers) do
      hl.dispatch(dispatcher)
    end
  end
end

local function exec(command)
  return hl.dsp.exec_cmd(command)
end

local function focus(direction)
  return hl.dsp.focus({ direction = direction })
end

local function move(options)
  return hl.dsp.window.move(options)
end

local function resize(x, y)
  return hl.dsp.window.resize({
    x = x,
    y = y,
    relative = true,
  })
end

local function workspace(workspace_id)
  return hl.dsp.focus({ workspace = workspace_id })
end

local function special_workspace(name)
  return hl.dsp.workspace.toggle_special(name)
end

local function submap(name)
  return hl.dsp.submap(name)
end

local function clear_notification()
  return exec("noctalia msg notification-clear-active")
end

local function one_shot(keys, dispatcher, description)
  bind(keys, sequence(clear_notification(), dispatcher, submap("reset")), description)
end

local function exit_mode(keys)
  bind(keys, sequence(clear_notification(), submap("reset")), "Exit mode")
end

bind("SUPER + RETURN", exec("alacritty"), "Open terminal")
bind("SUPER + E", exec("noctalia msg panel-toggle launcher"), "Open launcher")
bind("SUPER + P", exec("noctalia msg panel-toggle session"), "Open session panel")
bind("SUPER + Q", hl.dsp.window.close(), "Close active window")
bind("ALT + TAB", exec("noctalia msg window-switcher"), "Open window switcher")

bind("SUPER + F", hl.dsp.window.fullscreen({ mode = 1 }), "Toggle fullscreen")
bind("SUPER + SHIFT + F", hl.dsp.window.fullscreen({}), "Toggle full fullscreen")

for _, item in ipairs({
  { "SUPER + H", "left", "Focus left" },
  { "SUPER + J", "down", "Focus down" },
  { "SUPER + K", "up", "Focus up" },
  { "SUPER + L", "right", "Focus right" },
}) do
  bind(item[1], focus(item[2]), item[3])
end

for _, item in ipairs({
  { "SUPER + SHIFT + H", "left", "Move window left" },
  { "SUPER + SHIFT + J", "down", "Move window down" },
  { "SUPER + SHIFT + K", "up", "Move window up" },
  { "SUPER + SHIFT + L", "right", "Move window right" },
}) do
  bind(item[1], move({ direction = item[2] }), item[3])
end

bind("SUPER + T", hl.dsp.layout("togglesplit"), "Toggle split")
bind("SUPER + U", hl.dsp.window.float({ action = "toggle" }), "Toggle floating")

for workspace_id = 1, 5 do
  bind(
    "SUPER + " .. workspace_id,
    workspace(tostring(workspace_id)),
    "Focus workspace " .. workspace_id
  )
end

bind("SUPER + O", special_workspace("scratchy"), "Toggle scratch workspace")
bind("SUPER + M", special_workspace("aux"), "Toggle auxiliary workspace")
bind("SUPER + SHIFT + O", move({ workspace = "special:scratchy" }), "Move window to scratch workspace")
bind("SUPER + SHIFT + M", move({ workspace = "special:aux" }), "Move window to auxiliary workspace")

bind("SUPER + Z", exec("mumble rpc togglemute"), "Toggle Mumble mute")
bind("SUPER + SHIFT + Z", exec("mumble rpc toggledeaf"), "Toggle Mumble deafen")
bind("SUPER + period", exec("noctalia msg panel-toggle launcher /emo"), "Open emoji launcher")
bind("SUPER + SHIFT + I", exec("systemctl restart --user kanshi.service"), "Restart Kanshi")

bind("SUPER + mouse:272", hl.dsp.window.drag(), "Move window with mouse", { mouse = true })
bind("SUPER + mouse:273", hl.dsp.window.resize(), "Resize window with mouse", { mouse = true })

bind(
  "SUPER + N",
  sequence(
    exec("noctalia msg notification-show 'MODE: NOCTALIA' '[n] Notifications  [m] System  [v] Clipboard  [c] Calendar  [s] Region  [S] Full  [a] Annotate'"),
    submap("noctalia")
  ),
  "Enter noctalia mode"
)
bind(
  "SUPER + R",
  sequence(
    exec("noctalia msg notification-show 'MODE: RESIZE' '[H/J/K/L] Resize  [Shift+H/J/K/L] Fine  [Esc/Enter] Exit'"),
    submap("resize")
  ),
  "Enter resize mode"
)
bind(
  "SUPER + G",
  sequence(
    exec("noctalia msg notification-show 'MODE: WINDOWS' '[Q/W/E/R] Move to WS  [B] Toggle Firefox  [Esc/Enter] Exit'"),
    submap("windows")
  ),
  "Enter windows mode"
)

hl.define_submap("noctalia", function()
  one_shot("N", exec("noctalia msg panel-toggle control-center notifications"), "Open notifications")
  one_shot("M", exec("noctalia msg panel-toggle control-center system"), "Open system monitor")
  one_shot("V", exec("noctalia msg panel-toggle clipboard"), "Open clipboard")
  one_shot("C", exec("noctalia msg panel-toggle control-center calendar"), "Open calendar")
  one_shot("S", exec("noctalia msg screenshot-region"), "Capture region")
  one_shot("SHIFT + S", exec("noctalia msg screenshot-fullscreen"), "Capture screen")
  bind(
    "A",
    sequence(
      clear_notification(),
      exec("sleep 0.1; grim -g \"$(slurp)\" - | satty --filename -"),
      submap("reset")
    ),
    "Capture annotated region"
  )
  exit_mode("RETURN")
  exit_mode("ESCAPE")
end)

hl.define_submap("resize", function()
  for _, item in ipairs({
    { "H", -60, 0, "Resize left" },
    { "J", 0, 60, "Resize down" },
    { "K", 0, -60, "Resize up" },
    { "L", 60, 0, "Resize right" },
    { "SHIFT + H", -20, 0, "Resize left finely" },
    { "SHIFT + J", 0, 20, "Resize down finely" },
    { "SHIFT + K", 0, -20, "Resize up finely" },
    { "SHIFT + L", 20, 0, "Resize right finely" },
  }) do
    bind(item[1], resize(item[2], item[3]), item[4])
  end
  exit_mode("RETURN")
  exit_mode("ESCAPE")
end)

hl.define_submap("windows", function()
  for _, item in ipairs({
    { "Q", "1", "Move window to workspace 1" },
    { "W", "2", "Move window to workspace 2" },
    { "E", "3", "Move window to workspace 3" },
    { "R", "4", "Move window to workspace 4" },
  }) do
    one_shot(item[1], move({ workspace = item[2] }), item[3])
  end
  one_shot("B", exec("toggleFirefox"), "Toggle Firefox")
  exit_mode("RETURN")
  exit_mode("ESCAPE")
end)

local MODES = {
  resize = {
    glyph = "arrows-maximize",
    label = "MODE: RESIZE",
    tooltip = "MODE: RESIZE — [H/J/K/L] Resize  [Shift+H/J/K/L] Fine  [Esc/Enter] Exit",
  },
  windows = {
    glyph = "app-window",
    label = "MODE: WINDOWS",
    tooltip = "MODE: WINDOWS — [Q/W/E/R] Move to WS  [B] Toggle Firefox  [Esc/Enter] Exit",
  },
  noctalia = {
    glyph = "sparkles",
    label = "MODE: NOCTALIA",
    tooltip = "MODE: NOCTALIA — [n] Notifications  [m] Monitor  [c] Calendar  [s] Region  [S] Full  [a] Annotate",
  },
}

local currentSubmap = ""

local function applySubmap(mode)
  mode = mode or ""
  mode = string.gsub(mode, "^%s*(.-)%s*$", "%1")

  if mode == "" or mode == "reset" or mode == "default" then
    currentSubmap = ""
    barWidget.setVisible(false)
    barWidget.setText("")
    barWidget.clearTooltip()
    return
  end

  currentSubmap = mode
  local modeInfo = MODES[string.lower(mode)]
  if modeInfo then
    barWidget.setGlyph(modeInfo.glyph)
    barWidget.setText(modeInfo.label)
    barWidget.setTooltip(modeInfo.tooltip)
  else
    barWidget.setGlyph("command")
    barWidget.setText("MODE: " .. string.upper(mode))
    barWidget.setTooltip("MODE: " .. string.upper(mode) .. " — [Esc/Enter] Exit")
  end
  barWidget.setVisible(true)
end

local function onSocketLine(line)
  if not line then
    return
  end
  if string.sub(line, 1, 8) == "submap>>" then
    local mode = string.sub(line, 9)
    applySubmap(mode)
  end
end

local function startHyprlandStream()
  local runtimeDir = noctalia.getenv("XDG_RUNTIME_DIR")
  local his = noctalia.getenv("HYPRLAND_INSTANCE_SIGNATURE")
  if not runtimeDir or not his or runtimeDir == "" or his == "" then
    return false
  end

  local socketPath = runtimeDir .. "/hypr/" .. his .. "/.socket2.sock"
  local cmd = "socat -u UNIX-CONNECT:" .. socketPath .. " -"
  return noctalia.runStream(cmd, onSocketLine)
end

-- Initialize widget state
applySubmap("")
startHyprlandStream()

noctalia.runAsync({ "hyprctl", "submap" }, function(result)
  if result and result.exitCode == 0 and result.stdout then
    applySubmap(result.stdout)
  end
end)

function update()
  noctalia.setUpdateInterval(5000)
  noctalia.runAsync({ "hyprctl", "submap" }, function(result)
    if result and result.exitCode == 0 and result.stdout then
      local mode = string.gsub(result.stdout, "^%s*(.-)%s*$", "%1")
      if mode ~= currentSubmap then
        applySubmap(mode)
      end
    end
  end)
end

function onClick()
  noctalia.runAsync({ "hyprctl", "dispatch", "submap", "reset" })
end

function onIpc(event, payload)
  if event == "set" then
    applySubmap(payload)
  elseif event == "reset" then
    applySubmap("")
  end
end

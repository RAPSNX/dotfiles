local metrics = require("./metrics.luau")
noctalia.setUpdateInterval(2000)
barWidget.setGlyph("activity")

local function render()
  local stats = noctalia.systemStats()
  local load = stats and stats.loadAvg
  barWidget.setText(load and load[1] and string.format("%.1f", load[1]) or "—")
  barWidget.setTooltip("Load average · 1 minute\n1 / 5 / 15 min: " .. metrics.loadText(stats)
    .. "\nPressure CPU / I/O / memory: " .. metrics.pressureText() .. " (10 s)"
    .. "\nClick: top five sampled load contributors · Right click: System tab")
end

function update()
  render()
  metrics.refreshPressure(render)
end

function onClick()
  noctalia.togglePanel("rapsnx/system-load:processes")
end

update()

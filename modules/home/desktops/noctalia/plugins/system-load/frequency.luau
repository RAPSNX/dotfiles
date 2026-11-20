local metrics = require("./metrics.luau")
noctalia.setUpdateInterval(2000)

function update()
  local stats = noctalia.systemStats()
  local cpu = stats and stats.cpu or {}
  local values = metrics.cpuValues(stats)
  barWidget.render(ui.row({ gap = 8, align = "center" }, {
    ui.glyph({ name = "cpu" }),
    ui.label({ text = values.frequency }),
    ui.label({ text = "·", color = "on_surface_variant" }),
    ui.label({ text = values.usage, color = metrics.highlight(cpu.usagePercent, "cpu_usage") }),
    ui.label({ text = "·", color = "on_surface_variant" }),
    ui.label({ text = values.temperature, color = metrics.highlight(cpu.tempC, "cpu_temp") }),
  }))
  barWidget.setTooltip("CPU frequency · utilization · temperature\nAverage current frequency, updated every 2 seconds\nClick to open the System tab")
end

update()

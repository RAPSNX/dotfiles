local M = {}
local resources = { "cpu", "io", "memory" }
local pressure = {}
local readingPressure = false

function M.refreshPressure(callback)
  if readingPressure then return false end
  readingPressure = true
  local remaining = #resources
  local function finishRead()
    remaining -= 1
    if remaining == 0 then
      readingPressure = false
      callback()
    end
  end
  for _, resource in ipairs(resources) do
    local accepted = noctalia.readFileAsync("/proc/pressure/" .. resource, function(contents)
      local value = contents and string.match(contents, "some avg10=([%d.]+)")
      pressure[resource] = value and { value = tonumber(value), at = noctalia.nowMs() } or nil
      finishRead()
    end)
    if not accepted then finishRead() end
  end
  return true
end

function M.pressureValue(resource)
  local p = pressure[resource]
  return p and noctalia.nowMs() - p.at < 6000 and p.value or nil
end

function M.pressureText()
  local values = {}
  for _, resource in ipairs(resources) do
    local value = M.pressureValue(resource)
    table.insert(values, value and string.format("%.0f", value) or "—")
  end
  return table.concat(values, "/") .. "%"
end

function M.loadText(stats)
  local load = stats and stats.loadAvg
  if not load or #load < 3 then
    return "—/—/—"
  end
  return string.format("%.1f/%.1f/%.1f", load[1], load[2], load[3])
end

function M.cpuValues(stats)
  local cpu = stats and stats.cpu or {}
  return {
    frequency = cpu.freqMhz and cpu.freqMhz > 0 and string.format("%.0f MHz", cpu.freqMhz) or "— MHz",
    usage = cpu.usagePercent and string.format("%.0f%%", cpu.usagePercent) or "—",
    temperature = cpu.tempC and string.format("%.0f°C", cpu.tempC) or "—",
  }
end

function M.highlight(value, stat)
  if value == nil then return "on_surface" end
  local critical = noctalia.getSetting("system.monitor." .. stat .. "_critical_threshold")
  local activity = noctalia.getSetting("system.monitor." .. stat .. "_activity_threshold")
  if not critical or critical == 0 then return "on_surface" end
  if value >= critical then return "error" end
  return activity and value >= activity and "primary" or "on_surface"
end

return M

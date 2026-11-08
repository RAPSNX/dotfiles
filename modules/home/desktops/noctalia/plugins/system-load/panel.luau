local metrics = require("./metrics.luau")
local model = require("./model.luau")
local history = model.new()
local active = false
local busy = false
local generation = 0
local result = nil
local receivedAt = nil
local errorText = nil
local mode = "cpu"
local expanded = {}
noctalia.setUpdateInterval(2000)

local function caption(text)
  return ui.label({ text = text, fontSize = 11, color = "on_surface_variant", maxLines = 1 })
end

local function metricCard(title, value, color, surface)
  return ui.column({ gap = 4, padding = 10, radius = 10, fill = surface, flexGrow = 1 }, {
    caption(title),
    ui.label({ text = value, fontSize = 18, fontWeight = "semibold", color = color or "on_surface", maxLines = 1 }),
  })
end

local function notice(text, glyph, color, surface)
  return ui.row({ gap = 8, padding = 10, radius = 10, fill = surface, align = "center" }, {
    ui.glyph({ name = glyph, size = 16, color = color }),
    ui.label({ text = text, fontSize = 12, color = color, maxLines = 2, flexGrow = 1 }),
  })
end

local function render()
  if not active then return end
  local stats = noctalia.systemStats()
  local cpu = stats and stats.cpu or {}
  local values = metrics.cpuValues(stats)
  local surface = noctalia.getColor("surface_container")
  local track = noctalia.getColor("surface_container_high")
  local loads = {}
  for index, minutes in ipairs({ 1, 5, 15 }) do
    local value = stats and stats.loadAvg and stats.loadAvg[index]
    table.insert(loads, ui.column({ gap = 2, flexGrow = 1 }, {
      caption(tostring(minutes) .. " min"),
      ui.label({ text = value and string.format("%.1f", value) or "—", fontSize = 14, fontWeight = "semibold" }),
    }))
  end
  local pressure = {}
  for _, resource in ipairs({ { "cpu", "CPU" }, { "io", "I/O" }, { "memory", "Memory" } }) do
    local value = metrics.pressureValue(resource[1])
    table.insert(pressure, ui.column({ gap = 4, flexGrow = 1 }, {
      ui.row({ justify = "space_between", gap = 4 }, {
        caption(resource[2]), caption(value and string.format("%.0f%%", value) or "—"),
      }),
      ui.progress({ progress = value and math.min(1, math.max(0, value / 100)) or 0,
        fill = "primary", track = track, height = 3, opacity = value and 1 or 0.3 }),
    }))
  end
  local children = {
    ui.row({ gap = 8, align = "center" }, {
      ui.glyph({ name = "activity", size = 18, color = "primary" }),
      ui.label({ text = "System activity", fontSize = 18, fontWeight = "semibold" }),
    }),
    ui.row({ gap = 8 }, {
      metricCard("Frequency", values.frequency, nil, surface),
      metricCard("CPU", values.usage, metrics.highlight(cpu.usagePercent, "cpu_usage"), surface),
      metricCard("Temperature", values.temperature, metrics.highlight(cpu.tempC, "cpu_temp"), surface),
    }),
    ui.column({ padding = 10, gap = 8, radius = 10, fill = surface }, {
      ui.row({ gap = 12, align = "center" }, {
        ui.label({ text = "Load average", fontSize = 12, width = 104 }),
        ui.row({ gap = 12, flexGrow = 1 }, loads),
      }),
      ui.separator({ spacing = 0 }),
      ui.row({ gap = 12, tooltip = "Resource pressure: percentage of time with at least one task stalled, over the recent 10-second window." }, pressure),
    }),
    ui.row({ gap = 6, align = "center" }, {
      ui.label({ text = "Top applications", fontSize = 14, fontWeight = "semibold", flexGrow = 1 }),
      ui.button({ text = "CPU", controlSize = "sm", selected = mode == "cpu", onClick = function()
        mode = "cpu"; expanded = {}; render()
      end }),
      ui.button({ text = "Blocked", controlSize = "sm", selected = mode == "blocked", onClick = function()
        mode = "blocked"; expanded = {}; render()
      end }),
    }),
  }
  if receivedAt and noctalia.nowMs() - receivedAt > 6000 then
    table.insert(children, notice("Stale process sample — waiting for collector", "clock", "error", surface))
  elseif errorText then
    table.insert(children, notice(errorText, "alert-circle", "error", surface))
  end
  if result then
    local rows = {}
    local ranked = model.rows(result, mode)
    local field = mode == "blocked" and "d" or "cpu"
    local maximum = ranked[1] and ranked[1][field] or 1
    for _, p in ipairs(ranked) do
      local contents = {
        ui.row({ gap = 8, align = "center", tooltip = "Click to show the busiest child processes.", onClick = function()
          expanded[p.key] = not expanded[p.key]; render()
        end }, {
          ui.glyph({ name = expanded[p.key] and "chevron-down" or "chevron-right", size = 14, color = "on_surface_variant" }),
          ui.column({ gap = 0, flexGrow = 1 }, {
            ui.label({ text = p.name, fontSize = 14, fontWeight = "semibold", maxLines = 1, maxWidth = 220 }),
            caption(tostring(#p.children) .. " processes" .. (p.pid > 0 and " · PID " .. tostring(p.pid) or "")),
          }),
          ui.column({ gap = 0, width = 190, align = "end" }, {
            ui.label({ text = p.cpu and string.format("%.0f%%", p.cpu) or "—", fontSize = 14, textAlign = "right" }),
            ui.label({ text = string.format("Runnable %.1f · Blocked %.1f", p.r, p.d),
              fontSize = 10, textAlign = "right", maxLines = 1, maxWidth = 190,
              color = p.d > 0 and "primary" or "on_surface_variant" }),
          }),
        }),
        ui.column({ tooltip = mode == "cpu" and "Measured CPU usage relative to the highest displayed application."
          or "Sampled blocked threads relative to the highest displayed application." }, {
          ui.progress({ progress = p[field] / maximum, height = 3, fill = "primary", track = track }),
        }),
      }
      if expanded[p.key] then
        for _, child in ipairs(model.children(p, mode)) do
          table.insert(contents, ui.row({ key = "child-" .. tostring(child.pid), gap = 8, paddingH = 6,
            tooltip = child.role .. " · PID " .. tostring(child.pid), align = "center" }, {
            ui.column({ flexGrow = 1, gap = 1 }, {
              ui.label({ text = p.name .. " · " .. child.role, fontSize = 12, maxLines = 1, maxWidth = 290 }),
              caption("PID " .. tostring(child.pid)),
            }),
            ui.column({ width = 130, align = "end", gap = 1 }, {
              ui.label({ text = child.cpu and string.format("%.0f%%", child.cpu) or "—", fontSize = 12, textAlign = "right" }),
              caption(string.format("Blocked %.1f", child.d)),
            }),
          }))
        end
        if p.unmeasured > 0 then table.insert(contents, caption(tostring(p.unmeasured) .. " new processes awaiting a CPU baseline")) end
        if p.firefox then
          table.insert(contents, ui.button({ text = "Inspect in Firefox", glyph = "external-link", controlSize = "sm",
            tooltip = "Open about:processes, find the busy PID above, and use its profiler icon to investigate the website.",
            onClick = function()
              local command = noctalia.getConfig("firefox_command")
              if not noctalia.runAsync({ command, "--new-tab", "about:processes" }) then
                errorText = "Could not open Firefox's process manager."; render()
              end
            end }))
        end
      end
      table.insert(rows, ui.column({ key = p.key, gap = 4, paddingH = 10, paddingV = 6,
        radius = 8, fill = surface }, contents))
    end
    table.insert(children, ui.column({ gap = 4 }, rows))
    if #ranked == 0 then
      local message = mode == "blocked" and "No blocked tasks observed."
        or (not result.cpuReady and "Measuring CPU activity…" or "No CPU activity observed in this interval.")
      table.insert(children, notice(message, "circle-check", "on_surface_variant", surface))
    end
  else
    table.insert(children, notice("Collecting first sample…", "hourglass", "on_surface_variant", surface))
  end
  local details = "CPU ranks measured CPU-time deltas; Blocked ranks average sampled uninterruptibly blocked threads over 10 seconds.\n"
    .. "CPU: 100% = one logical CPU. Indicators are relative to the highest displayed row.\n"
    .. "Applications group same-executable parent/child processes. Kernel threads are separate.\n"
    .. "Blocked tasks may be victims of a bottleneck; short-lived work can be missed."
  if result then
    details = details .. string.format("\nWindow %.0f/10 s · scan %.0f ms · %d inaccessible entries",
      result.span, result.scanMs, result.inaccessible)
  end
  table.insert(children, ui.row({ gap = 6, align = "center", justify = "space_between", tooltip = details }, {
    caption(mode == "cpu" and "Measured CPU · latest interval"
      or (result and result.span < 10 and string.format("Sampling · %.0f/10 seconds", result.span)
        or "Sampled blocked threads · last 10 seconds")),
    ui.glyph({ name = "info-circle", size = 14, color = "on_surface_variant" }),
  }))
  panel.render(ui.scroll({ gap = 10, flexGrow = 1 }, children))
end

local function sample()
  if not active or busy then return end
  local command = noctalia.getConfig("collector")
  if not command or command == "" then
    errorText = "Process collector is not configured."
    render()
    return
  end
  busy = true
  local requestGeneration = generation
  local arguments = { command }
  local known = model.knownIdentities(history)
  if next(known) then
    local encoded = noctalia.json.encode(known)
    if encoded and #encoded < 24000 then
      table.insert(arguments, "--known-identities"); table.insert(arguments, encoded)
    end
  end
  local accepted = noctalia.runAsync(arguments, function(response)
    busy = false
    if not active or requestGeneration ~= generation then return end
    if response.exitCode ~= 0 or response.timedOut or response.stdoutTruncated then
      errorText = "Process collector failed; retrying."
    else
      local snapshot = noctalia.json.decode(response.stdout)
      if snapshot and snapshot.at and snapshot.processes then
        result = model.add(history, snapshot)
        receivedAt = noctalia.nowMs()
        errorText = nil
      else
        errorText = "Invalid process sample; retrying."
      end
    end
    render()
  end)
  if not accepted then
    busy = false
    errorText = "Could not start process collector; retrying."
    render()
  end
end

function update()
  if not active then return end
  metrics.refreshPressure(render)
  sample()
  render()
end

function onOpen()
  generation = generation + 1
  active = true
  history = model.new()
  mode = "cpu"
  expanded = {}
  result, receivedAt, errorText = nil, nil, nil
  update()
end

function onClose()
  active = false
  generation = generation + 1
  history = model.new()
  expanded = {}
  result, receivedAt = nil, nil
end

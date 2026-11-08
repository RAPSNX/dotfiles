-- Run with the local modules available through require; no running desktop needed.
local clock = 1000
local stats = { cpu = { freqMhz = 840, usagePercent = 72, tempC = 53 }, loadAvg = { 12, 9.5, 5.4 } }
local requests = {}
local rendered = nil
local text = nil
local responseData = nil
local openedPanel = nil
local bar = nil
local tooltip = nil
local launches = {}
local thresholds = {
  cpu_usage_activity_threshold = 50, cpu_usage_critical_threshold = 90,
  cpu_temp_activity_threshold = 60, cpu_temp_critical_threshold = 85,
}

noctalia = {
  setUpdateInterval = function(ms) assert(ms == 2000) end,
  systemStats = function() return stats end,
  nowMs = function() return clock end,
  getColor = function(_) return "#313244" end,
  getSetting = function(path) return thresholds[string.match(path, "system.monitor.(.+)")] end,
  readFileAsync = function(_, callback) callback("some avg10=8.00 avg60=1.00 avg300=0.10 total=5"); return true end,
  togglePanel = function(id) openedPanel = id end,
  getConfig = function(key)
    if key == "firefox_command" then return "/firefox" end
    assert(key == "collector"); return "/collector"
  end,
  runAsync = function(argv, callback)
    if argv[1] == "/firefox" then
      assert(#argv == 3 and argv[2] == "--new-tab" and argv[3] == "about:processes")
      table.insert(launches, argv); return true
    end
    assert(argv[1] == "/collector" and (#argv == 1 or (#argv == 3 and argv[2] == "--known-identities")))
    table.insert(requests, callback)
    return true
  end,
  json = { decode = function(_) return responseData end, encode = function(_) return "cached-identities" end },
}
barWidget = {
  setText = function(value) text = value end,
  setGlyph = function(_) end,
  setTooltip = function(value) tooltip = value end,
  render = function(tree) bar = tree end,
}
panel = { render = function(tree) rendered = tree end }
ui = {}
for _, kind in ipairs({ "label", "row", "column", "scroll", "separator", "glyph", "progress", "button" }) do
  ui[kind] = function(props, children) return { props = props, children = children or {} } end
end

local function contains(node, needle)
  if node.props.text and string.find(node.props.text, needle, 1, true) then return true end
  for _, child in ipairs(node.children) do
    if contains(child, needle) then return true end
  end
  return false
end

local function hasTooltip(node, needle)
  if node.props.tooltip and string.find(node.props.tooltip, needle, 1, true) then return true end
  for _, child in ipairs(node.children) do
    if hasTooltip(child, needle) then return true end
  end
  return false
end

local function findText(node, needle)
  if node.props.text == needle then return node end
  for _, child in ipairs(node.children) do
    local found = findText(child, needle)
    if found then return found end
  end
  return nil
end

local function checkProgress(node)
  if node.props.progress then assert(node.props.progress >= 0 and node.props.progress <= 1) end
  for _, child in ipairs(node.children) do checkProgress(child) end
end

require("./frequency.luau")
assert(contains(bar, "840 MHz") and contains(bar, "72%") and contains(bar, "53°C"))
assert(findText(bar, "72%").props.color == "primary")
assert(findText(bar, "53°C").props.color == "on_surface")
stats.cpu.tempC = 90
update()
assert(findText(bar, "90°C").props.color == "error")
thresholds.cpu_temp_critical_threshold = 0
update()
assert(findText(bar, "90°C").props.color == "on_surface")
thresholds.cpu_temp_critical_threshold = 85
stats = nil
update()
assert(contains(bar, "— MHz") and not contains(bar, "0%"))
stats = { cpu = { freqMhz = 4000, usagePercent = 20, tempC = 50 }, loadAvg = { 1, 2, 3 } }
require("./load.luau")
assert(text == "1.0")
assert(string.find(tooltip, "1.0/2.0/3.0", 1, true))
assert(string.find(tooltip, "8/8/8%", 1, true))
assert(#requests == 0) -- Bar widgets never scan processes.
onClick()
assert(openedPanel == "rapsnx/system-load:processes")

local function clickable(node, text)
  if node.props.onClick and contains(node, text) then return node end
  for _, child in ipairs(node.children) do
    local found = clickable(child, text)
    if found then return found end
  end
end

local function firefox(cpu)
  return {
    { pid = 20, ppid = 0, start = 1, name = ".firefox-wrappe", r = 0, d = 0, cpuSeconds = cpu / 10,
      identity = { exe = "/bin/firefox", label = "Firefox", role = "Browser", firefox = true } },
    { pid = 21, ppid = 20, start = 1, name = "Isolated Web Co", r = 0, d = 0, cpuSeconds = cpu,
      identity = { exe = "/bin/firefox", label = "Firefox", role = "Web content", firefox = true } },
    { pid = 30, ppid = 2, start = 1, name = "kworker/u64:1", kernel = true, r = 0, d = 3, cpuSeconds = 0 },
  }
end

require("./panel.luau")
onOpen()
assert(#requests == 1 and contains(rendered, "Collecting first sample"))
assert(contains(rendered, "System activity") and contains(rendered, "Top applications"))
update()
assert(#requests == 1) -- No overlapping scans.
onClose()
update()
assert(#requests == 1) -- No scans while closed.
responseData = { at = 1, processes = {}, inaccessible = 0, scanMs = 20 }
requests[1]({ exitCode = 0, stdout = "sample" }) -- Late response is ignored.
onOpen()
assert(#requests == 2)
responseData = { at = 2, processes = firefox(0), inaccessible = 1, scanMs = 20 }
requests[2]({ exitCode = 0, stdout = "sample" })
assert(contains(rendered, "Measuring CPU activity") and not contains(rendered, "Kernel workers"))
assert(not contains(rendered, "1 inaccessible") and hasTooltip(rendered, "1 inaccessible"))
findText(rendered, "Blocked").props.onClick()
assert(contains(rendered, "Kernel workers") and contains(rendered, "Blocked 3.0"))
clickable(rendered, "CPU").props.onClick()
update()
assert(#requests == 3)
responseData = { at = 4, processes = firefox(2.4), inaccessible = 0, scanMs = 20 }
requests[3]({ exitCode = 0, stdout = "sample" })
assert(contains(rendered, "Firefox") and contains(rendered, "132%"))
assert(not contains(rendered, "Isolated Web Co") and not contains(rendered, "Kernel workers"))
clickable(rendered, "Firefox").props.onClick()
assert(contains(rendered, "Firefox · Web content") and contains(rendered, "PID 21"))
assert(contains(rendered, "120%"))
findText(rendered, "Inspect in Firefox").props.onClick()
assert(#launches == 1)
checkProgress(rendered)
clock = 9000
update()
assert(contains(rendered, "Stale process sample"))
requests[4]({ exitCode = 1, stdout = "" })
onClose()
onOpen()
responseData = nil
requests[5]({ exitCode = 0, stdout = "invalid" })
assert(contains(rendered, "Invalid process sample"))
-- Five independent applications with long names and >100% CPU stay bounded.
local function applications(cpu)
  local processes = {}
  for pid = 101, 105 do
    table.insert(processes, { pid = pid, ppid = 0, start = 1, r = 0, d = 0, cpuSeconds = cpu,
      name = "a very long application name with several words " .. pid })
  end
  return processes
end
update()
responseData = { at = 6, processes = applications(0), inaccessible = 0, scanMs = 20 }
requests[6]({ exitCode = 0, stdout = "sample" })
update()
responseData = { at = 8, processes = applications(8), inaccessible = 0, scanMs = 20 }
requests[7]({ exitCode = 0, stdout = "sample" })
assert(contains(rendered, "400%"))
assert(findText(rendered, "a very long application name with several words 101").props.maxLines == 1)
assert(findText(rendered, "a very long application name with several words 101").props.maxWidth == 220)
checkProgress(rendered)
onClose()
print("Application UI, inspection actions, and panel lifecycle tests passed")

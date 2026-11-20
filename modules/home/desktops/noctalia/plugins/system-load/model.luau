-- CPU deltas are measured work; blocked-thread occupancy is sampled over ten seconds.
local M = {}

function M.new()
  return { history = {}, started = nil, identities = {} }
end

local function processId(process)
  return tostring(process.pid) .. ":" .. tostring(process.start)
end

function M.knownIdentities(model)
  local known = {}
  for id, cached in pairs(model.identities) do known[id] = cached.name end
  return known
end

local function rootProcess(process, byPid)
  local root, seen = process, {}
  local executable = process.identity.exe
  while executable and executable ~= "" and not seen[root.pid] do
    seen[root.pid] = true
    local parent = byPid[root.ppid]
    if not parent or parent.identity.exe ~= executable or seen[parent.pid] then break end
    root = parent
  end
  return root
end

function M.add(model, sample)
  local history = model.history
  local previous = history[#history]
  if previous and (sample.at <= previous.at or sample.at - previous.at > 8) then
    history = {}
    model.history = history
    model.started = nil
    previous = nil
  end
  model.started = model.started or sample.at
  sample.byId = {}
  local byPid, identities = {}, {}
  for _, process in ipairs(sample.processes) do
    local id = processId(process)
    local cached = model.identities[id]
    process.identity = process.identity or (cached and cached.name == process.name and cached.identity)
      or { label = process.name, role = process.name, exe = "" }
    identities[id] = { name = process.name, identity = process.identity }
    sample.byId[id] = process
    byPid[process.pid] = process
  end
  model.identities = identities
  table.insert(history, sample)
  while #history > 1 and sample.at - history[1].at >= 10 do table.remove(history, 1) end

  local groups = {}
  for id, process in pairs(sample.byId) do
    local runnable, blocked = 0, 0
    for _, observation in ipairs(history) do
      local p = observation.byId[id]
      if p then
        runnable = runnable + p.r
        blocked = blocked + p.d
      end
    end
    local before = previous and previous.byId[id]
    local cpu = before and process.cpuSeconds >= before.cpuSeconds
      and (process.cpuSeconds - before.cpuSeconds) / (sample.at - previous.at) * 100 or nil
    local root = rootProcess(process, byPid)
    local key = process.kernel and "kernel" or "app:" .. processId(root)
    local group = groups[key]
    if not group then
      group = { key = key, name = process.kernel and "Kernel workers" or root.identity.label,
        pid = process.kernel and 0 or root.pid, firefox = not process.kernel and root.identity.firefox,
        cpu = nil, r = 0, d = 0, children = {}, unmeasured = 0 }
      groups[key] = group
    end
    group.r = group.r + runnable / #history
    group.d = group.d + blocked / #history
    if cpu ~= nil then group.cpu = (group.cpu or 0) + cpu else group.unmeasured = group.unmeasured + 1 end
    table.insert(group.children, { pid = process.pid, role = process.identity.role,
      cpu = cpu, r = runnable / #history, d = blocked / #history })
  end
  return { groups = groups, cpuReady = previous ~= nil, span = math.min(10, sample.at - model.started),
    inaccessible = sample.inaccessible, scanMs = sample.scanMs }
end

local function rank(rows, mode)
  local field = mode == "blocked" and "d" or "cpu"
  local result = {}
  for _, row in pairs(rows) do
    if (row[field] or 0) > 0 then table.insert(result, row) end
  end
  table.sort(result, function(a, b)
    if a[field] ~= b[field] then return a[field] > b[field] end
    if (a.cpu or 0) ~= (b.cpu or 0) then return (a.cpu or 0) > (b.cpu or 0) end
    return a.pid < b.pid
  end)
  while #result > 5 do table.remove(result) end
  return result
end

function M.rows(result, mode)
  return rank(result.groups, mode)
end

function M.children(group, mode)
  return rank(group.children, mode)
end

return M

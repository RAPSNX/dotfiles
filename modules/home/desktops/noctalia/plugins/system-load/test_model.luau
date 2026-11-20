local model = require("./model.luau")

local function process(pid, options)
  local p = { pid = pid, ppid = 0, name = "process " .. pid, r = 0, d = 0,
    cpuSeconds = 0, start = 1, kernel = false,
    identity = { exe = "/bin/task" .. pid, label = "App " .. pid, role = "Worker" } }
  for key, value in pairs(options or {}) do p[key] = value end
  return p
end
local function sample(at, processes)
  return { at = at, processes = processes, inaccessible = 0, scanMs = 10 }
end
local function firefox(pid, parent, cpu)
  return process(pid, { ppid = parent, cpuSeconds = cpu,
    identity = { exe = "/bin/firefox", label = "Firefox", role = parent == 0 and "Browser" or "Web content", firefox = true } })
end

-- Measured CPU includes sleeping processes, regardless of instantaneous R/D samples.
local m = model.new()
model.add(m, sample(0, { process(1), process(2, { d = 3 }) }))
local result = model.add(m, sample(2, { process(1, { cpuSeconds = 4 }), process(2, { d = 3 }) }))
local cpu = model.rows(result, "cpu")
local blocked = model.rows(result, "blocked")
assert(#cpu == 1 and cpu[1].pid == 1 and cpu[1].cpu == 200)
assert(#blocked == 1 and blocked[1].pid == 2 and blocked[1].cpu == 0)

-- Browser parent, forkserver and workers aggregate CPU without double-counting.
m = model.new()
model.add(m, sample(0, { firefox(10, 0, 0), firefox(11, 10, 0), firefox(12, 11, 0) }))
result = model.add(m, sample(2, { firefox(10, 0, 0), firefox(11, 10, 2), firefox(12, 11, 4) }))
cpu = model.rows(result, "cpu")
assert(#cpu == 1 and cpu[1].name == "Firefox" and cpu[1].cpu == 300 and #cpu[1].children == 3)
assert(model.children(cpu[1], "cpu")[1].pid == 12 and cpu[1].firefox)

-- Cache metadata by PID/start/name; no stale identities after PID reuse or rename.
local cached = firefox(12, 11, 6); cached.identity = nil
local known = model.knownIdentities(m)
assert(known["12:1"] == "process 12")
result = model.add(m, sample(4, { firefox(10, 0, 0), firefox(11, 10, 2), cached }))
assert(model.rows(result, "cpu")[1].name == "Firefox")
local reused = process(12, { start = 2, cpuSeconds = 1 })
result = model.add(m, sample(6, { reused }))
assert(#model.rows(result, "cpu") == 0 and not model.knownIdentities(m)["12:1"])
assert(not model.knownIdentities(m)["10:1"])
local renamed = process(12, { start = 2, name = "renamed", cpuSeconds = 2 }); renamed.identity = nil
result = model.add(m, sample(8, { renamed }))
assert(model.rows(result, "cpu")[1].name == "renamed")

-- Independent jobs with the same executable remain separate; workers join their parent.
local identity = { exe = "/bin/python3", label = "Python", role = "Worker" }
m = model.new()
model.add(m, sample(0, { process(20, { identity = identity }), process(21, { ppid = 20, identity = identity }), process(30, { identity = identity }) }))
result = model.add(m, sample(2, { process(20, { identity = identity, cpuSeconds = 1 }),
  process(21, { ppid = 20, identity = identity, cpuSeconds = 1 }), process(30, { identity = identity, cpuSeconds = 1 }) }))
cpu = model.rows(result, "cpu")
assert(#cpu == 2 and cpu[1].pid == 20 and cpu[1].cpu == 100 and cpu[2].pid == 30)

-- Reparenting changes group membership, but per-PID CPU deltas stay accurate.
result = model.add(m, sample(4, { process(20, { identity = identity, cpuSeconds = 1 }),
  process(21, { ppid = 30, identity = identity, cpuSeconds = 3 }), process(30, { identity = identity, cpuSeconds = 2 }) }))
cpu = model.rows(result, "cpu")
assert(#cpu == 1 and cpu[1].pid == 30 and cpu[1].cpu == 150)

-- Kernel workers have a separate group, including blocked workers with zero CPU.
m = model.new()
result = model.add(m, sample(0, { process(40, { kernel = true, d = 2 }), process(41, { kernel = true, d = 1 }) }))
blocked = model.rows(result, "blocked")
assert(#blocked == 1 and blocked[1].name == "Kernel workers" and blocked[1].d == 3)
assert(#model.rows(result, "cpu") == 0)

-- Expired blocked observations disappear; exits, long gaps, and counters reset safely.
for t = 2, 10, 2 do result = model.add(m, sample(t, { process(40, { kernel = true }) })) end
assert(#model.rows(result, "blocked") == 0)
result = model.add(m, sample(12, {}))
assert(next(result.groups) == nil)
result = model.add(m, sample(40, { process(1, { cpuSeconds = 100, d = 1 }) }))
assert(not result.cpuReady and result.span == 0 and #model.rows(result, "cpu") == 0)
result = model.add(m, sample(42, { process(1, { cpuSeconds = 1 }) }))
assert(#model.rows(result, "cpu") == 0)

-- Deterministic ties and the five-group limit.
m = model.new()
local initial, current = {}, {}
for pid = 8, 1, -1 do
  table.insert(initial, process(pid)); table.insert(current, process(pid, { cpuSeconds = 2 }))
end
model.add(m, sample(0, initial)); result = model.add(m, sample(2, current))
cpu = model.rows(result, "cpu")
assert(#cpu == 5 and cpu[1].pid == 1 and cpu[5].pid == 5)

print("Application grouping and CPU/blocked ranking tests passed")

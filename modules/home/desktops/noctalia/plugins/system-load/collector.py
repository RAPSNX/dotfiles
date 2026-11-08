#!/usr/bin/env python3
"""Read-only Linux snapshots for Noctalia and bounded manual JSONL captures."""

import argparse
import configparser
import datetime
import json
import os
from pathlib import Path
import shlex
import sys
import time


def read(path):
    try:
        return Path(path).read_text()
    except (OSError, UnicodeError):
        return None


def parse_stat(text):
    end = text.rindex(")")
    fields = text[end + 2 :].split()
    return {
        "name": "".join(c if c.isprintable() else "?" for c in text[text.index("(") + 1 : end]),
        "state": fields[0],
        "ppid": int(fields[1]),
        "kernel": bool(int(fields[6]) & 0x00200000),
        "ticks": int(fields[11]) + int(fields[12]),
        "start": int(fields[19]),
    }


def clean_name(name):
    name = name.removesuffix(" (deleted)").lstrip(".")
    for suffix in ("-wrapped", "-wrapper"):
        name = name.removesuffix(suffix)
    return name


def desktop_names():
    """Read application metadata, never process arguments or browser history."""
    roots = [Path(os.environ.get("XDG_DATA_HOME", str(Path.home() / ".local/share"))),
             Path.home() / ".nix-profile/share"]
    roots += [Path(p) for p in os.environ.get("XDG_DATA_DIRS", "/usr/local/share:/usr/share").split(":") if p]
    names = {}
    for root in roots:
        for desktop in sorted((root / "applications").glob("*.desktop")):
            config = configparser.ConfigParser(interpolation=None, strict=False)
            config.optionxform = str
            try:
                config.read_string(desktop.read_text())
                entry = config["Desktop Entry"]
                label = entry.get("Name")
                if not label:
                    continue
                keys = [desktop.stem, entry.get("StartupWMClass", "")]
                command = shlex.split(entry.get("Exec", ""))
                if command and Path(command[0]).name != "env":
                    keys.append(Path(command[0]).name)
                for key in keys:
                    if key:
                        names.setdefault(clean_name(key).lower(), label)
            except (OSError, ValueError, KeyError, configparser.Error):
                continue
    return names


def process_identity(entry, leader, names):
    try:
        executable = os.readlink(entry / "exe").removesuffix(" (deleted)")
    except OSError:
        executable = ""
    binary = clean_name(Path(executable).name) if executable else clean_name(leader["name"])
    label = names.get(binary.lower(), binary)
    role = leader["name"]
    firefox = binary.lower() == "firefox"
    if leader["kernel"]:
        label = "Kernel workers"
    elif firefox:
        label = names.get("firefox", "Firefox")
        if role.startswith(("Isolated Web", "Web Content")):
            role = "Web content"
        else:
            role = {"WebExtensions": "Extensions", "RDD Process": "Media decoder",
                    "Socket Process": "Network", "Utility Process": "Utility",
                    "Privileged Cont": "Browser content", "forkserver": "Process launcher"}.get(role, "Browser")
    elif binary.lower() in ("chrome", "chromium", "chromium-browser"):
        label = names.get("chromium", names.get("chromium-browser", "Chromium"))
        role = "Browser process"
    return {"exe": executable, "label": label, "role": role, "firefox": firefox}


def process_snapshot(proc=Path("/proc"), known=None):
    started = time.monotonic()
    processes, inaccessible = [], 0
    clock_ticks = os.sysconf("SC_CLK_TCK")
    names = None
    known = known or {}
    for entry in proc.iterdir():
        if not entry.name.isdecimal() or int(entry.name) == os.getpid():
            continue
        try:
            leader = parse_stat((entry / "stat").read_text())
            runnable = blocked = 0
            for task in (entry / "task").iterdir():
                try:
                    stat = leader if task.name == entry.name else parse_stat((task / "stat").read_text())
                    runnable += stat["state"] == "R"
                    blocked += stat["state"] == "D"
                except PermissionError:
                    inaccessible += 1
                except (OSError, ValueError, IndexError):
                    # Threads can exit between enumeration and reading stat.
                    continue
            process = {
                "pid": int(entry.name),
                "ppid": leader["ppid"],
                "kernel": leader["kernel"],
                "start": leader["start"],
                "name": leader["name"],
                "cpuSeconds": leader["ticks"] / clock_ticks,
                "r": runnable,
                "d": blocked,
            }
            identity_key = f"{entry.name}:{leader['start']}"
            if known.get(identity_key) != leader["name"]:
                if names is None:
                    names = desktop_names()
                process["identity"] = process_identity(entry, leader, names)
            processes.append(process)
        except PermissionError:
            inaccessible += 1
        except (OSError, ValueError, IndexError):
            continue
    return {
        # CLOCK_BOOTTIME includes suspend: the UI resets its baseline after resume.
        "at": time.clock_gettime(time.CLOCK_BOOTTIME),
        "timestamp": datetime.datetime.now(datetime.timezone.utc).isoformat(),
        "processes": processes,
        "inaccessible": inaccessible,
        "scanMs": (time.monotonic() - started) * 1000,
    }


def number(path, divisor=1):
    text = read(path)
    try:
        return float(text) / divisor if text is not None else None
    except ValueError:
        return None


def system_snapshot():
    pressure = {}
    for resource in ("cpu", "io", "memory"):
        text = read(f"/proc/pressure/{resource}")
        pressure[resource] = {
            fields[0]: {k: float(v) for k, v in (f.split("=") for f in fields[1:])}
            for fields in (line.split() for line in (text or "").splitlines())
        } or None
    cpu_stat = (read("/proc/stat") or "").splitlines()
    memory = {}
    for line in (read("/proc/meminfo") or "").splitlines():
        name, value = line.split(":", 1)
        if name in ("MemTotal", "MemAvailable", "SwapTotal", "SwapFree", "Dirty", "Writeback"):
            memory[name] = int(value.split()[0]) * 1024
    clocks = [
        value for p in Path("/sys/devices/system/cpu/cpufreq").glob("policy*/scaling_cur_freq")
        if (value := number(p, 1000)) is not None
    ]
    sensors = []
    for hwmon in Path("/sys/class/hwmon").glob("hwmon*"):
        name = (read(hwmon / "name") or "").strip()
        if name in ("k10temp", "coretemp", "amdgpu", "nvme"):
            sensors.append({
                "driver": name,
                "temperaturesC": {p.name: number(p, 1000) for p in hwmon.glob("temp*_input")},
                "powerW": {p.name: number(p, 1_000_000) for p in hwmon.glob("power*_average")},
            })
    gpu = {
        card.name: number(card / "device/gpu_busy_percent")
        for card in Path("/sys/class/drm").glob("card[0-9]*") if "-" not in card.name
    }
    return {
        "loadAvg": os.getloadavg(),
        "pressure": pressure,
        "cpuTicks": [int(v) for v in cpu_stat[0].split()[1:]] if cpu_stat else None,
        "cpuMhz": sum(clocks) / len(clocks) if clocks else None,
        "memoryBytes": memory,
        "sensors": sensors,
        "gpuBusyPercent": gpu,
        "platformProfile": (read("/sys/firmware/acpi/platform_profile") or "").strip() or None,
        "acOnline": {p.parent.name: number(p) for p in Path("/sys/class/power_supply").glob("*/online")},
    }


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--snapshot", action="store_true", help="emit one process snapshot for Noctalia")
    parser.add_argument("--known-identities", default="{}", help=argparse.SUPPRESS)
    parser.add_argument("--duration", type=float, default=120, help="capture seconds, 1–600 (default: 120)")
    parser.add_argument("--interval", type=float, default=2, help="sample seconds, 1–30 (default: 2)")
    parser.add_argument("--output", type=Path, help="new JSONL file (default: timestamped file in current directory)")
    args = parser.parse_args(argv)
    if not 1 <= args.duration <= 600 or not 1 <= args.interval <= 30:
        parser.error("duration must be 1–600 seconds and interval 1–30 seconds")
    if args.snapshot:
        try:
            known = json.loads(args.known_identities)
            if not isinstance(known, dict):
                raise ValueError("expected an object")
        except (ValueError, TypeError) as error:
            parser.error(f"invalid identity cache: {error}")
        print(json.dumps(process_snapshot(known=known), separators=(",", ":")))
        return
    output = args.output or Path(f"firefly-system-{time.strftime('%Y%m%d-%H%M%S')}.jsonl")
    # Never overwrite an existing capture or follow its symlink. No automatic logging.
    fd = os.open(output, os.O_WRONLY | os.O_CREAT | os.O_EXCL, 0o600)
    print(f"Capturing for up to {args.duration:g}s to {output}", file=sys.stderr)
    deadline = time.monotonic() + args.duration
    with os.fdopen(fd, "w") as stream:
        while time.monotonic() < deadline:
            sample_started = time.monotonic()
            snapshot = process_snapshot()
            snapshot["system"] = system_snapshot()
            stream.write(json.dumps(snapshot, separators=(",", ":")) + "\n")
            stream.flush()
            remaining = min(deadline - time.monotonic(), args.interval - (time.monotonic() - sample_started))
            if remaining > 0:
                time.sleep(remaining)


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        pass
    except OSError as error:
        print(f"Capture failed: {error}", file=sys.stderr)
        sys.exit(1)

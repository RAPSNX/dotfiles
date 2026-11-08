import importlib.util
import json
import os
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch

spec = importlib.util.spec_from_file_location("collector", Path(__file__).with_name("collector.py"))
collector = importlib.util.module_from_spec(spec)
spec.loader.exec_module(collector)


def stat(pid, name, state="S", ticks=100, start=25, ppid=0, kernel=False):
    fields = ["0"] * 22
    fields[0], fields[11], fields[19] = state, str(ticks), str(start)
    fields[1], fields[6] = str(ppid), str(0x00200000 if kernel else 0)
    return f"{pid} ({name}) " + " ".join(fields)


class CollectorTests(unittest.TestCase):
    def test_stat_names_with_parentheses_and_cpu_fields(self):
        result = collector.parse_stat(stat(42, "a (worker)\n", "D", ticks=250))
        self.assertEqual(result, {"name": "a (worker)?", "state": "D", "ticks": 250, "start": 25, "ppid": 0, "kernel": False})

    def test_counts_worker_threads_and_survives_exit_and_bad_stat(self):
        with tempfile.TemporaryDirectory() as directory:
            proc = Path(directory)
            (proc / "42/task").mkdir(parents=True)
            (proc / "42/stat").write_text(stat(42, "browser"))
            for tid, state in [(42, "S"), (43, "R"), (44, "D"), (45, "D")]:
                task = proc / f"42/task/{tid}"
                task.mkdir()
                (task / "stat").write_text(stat(tid, "worker", state))
            (proc / "42/task/46").mkdir()  # Thread has exited.
            (proc / "99").mkdir()
            (proc / "99/stat").write_text("malformed")
            result = collector.process_snapshot(proc)
        self.assertEqual(len(result["processes"]), 1)
        process = result["processes"][0]
        self.assertEqual((process["r"], process["d"]), (1, 2))
        self.assertEqual(process["cpuSeconds"], 100 / os.sysconf("SC_CLK_TCK"))
        self.assertNotIn("args", process)

    def test_permission_failure_is_reported(self):
        with tempfile.TemporaryDirectory() as directory:
            proc = Path(directory)
            (proc / "42").mkdir()
            with patch.object(Path, "read_text", side_effect=PermissionError):
                result = collector.process_snapshot(proc)
        self.assertEqual(result["inaccessible"], 1)
        self.assertEqual(result["processes"], [])

    def test_executable_identity_and_friendly_browser_roles(self):
        leader = collector.parse_stat(stat(42, "Isolated Web Co"))
        with patch.object(collector.os, "readlink", return_value="/nix/store/example/lib/firefox/firefox"):
            identity = collector.process_identity(Path("/proc/42"), leader, {"firefox": "Firefox"})
        self.assertEqual(identity["label"], "Firefox")
        self.assertEqual(identity["role"], "Web content")
        self.assertTrue(identity["firefox"])
        self.assertEqual(collector.clean_name(".alacritty-wrapped (deleted)"), "alacritty")

    def test_unreadable_executable_and_kernel_classification(self):
        leader = collector.parse_stat(stat(42, "daemon"))
        with patch.object(collector.os, "readlink", side_effect=PermissionError):
            identity = collector.process_identity(Path("/proc/42"), leader, {})
        self.assertEqual(identity["label"], "daemon")
        self.assertEqual(identity["exe"], "")
        leader = collector.parse_stat(stat(42, "kworker/u64:1", kernel=True))
        with patch.object(collector.os, "readlink", side_effect=FileNotFoundError):
            self.assertEqual(collector.process_identity(Path("/proc/42"), leader, {})["label"], "Kernel workers")

    def test_cached_identity_skips_metadata_and_renames_refresh_it(self):
        with tempfile.TemporaryDirectory() as directory:
            proc = Path(directory)
            (proc / "42/task/42").mkdir(parents=True)
            (proc / "42/stat").write_text(stat(42, "worker"))
            with patch.object(collector, "desktop_names", return_value={}) as names:
                result = collector.process_snapshot(proc, {"42:25": "worker"})
                self.assertNotIn("identity", result["processes"][0])
                names.assert_not_called()
                result = collector.process_snapshot(proc, {"42:25": "old name"})
                self.assertIn("identity", result["processes"][0])
                names.assert_called_once()

    def test_desktop_name_uses_main_entry_and_user_precedence(self):
        with tempfile.TemporaryDirectory() as directory:
            data = Path(directory)
            for name, label in [("user", "Firefox"), ("system", "System Firefox")]:
                applications = data / name / "applications"
                applications.mkdir(parents=True)
                (applications / "firefox.desktop").write_text(
                    f"[Desktop Entry]\nName={label}\nExec=firefox %U\n[Desktop Action private]\nName=Private Window\n")
            with patch.dict(os.environ, {"XDG_DATA_HOME": str(data / "user"), "XDG_DATA_DIRS": str(data / "system")}):
                self.assertEqual(collector.desktop_names()["firefox"], "Firefox")

    def test_missing_sensors_remain_unavailable(self):
        with patch.object(collector, "read", return_value=None), patch.object(Path, "glob", return_value=[]):
            system = collector.system_snapshot()
        self.assertIsNone(system["cpuMhz"])
        self.assertIsNone(system["pressure"]["cpu"])
        self.assertEqual(system["sensors"], [])

    def test_manual_capture_is_bounded_private_and_refuses_overwrite(self):
        with tempfile.TemporaryDirectory() as directory:
            output = Path(directory) / "capture.jsonl"
            with patch.object(collector, "process_snapshot", return_value={"processes": []}), \
                 patch.object(collector, "system_snapshot", return_value={}), \
                 patch.object(collector.time, "monotonic", side_effect=[0, 0, 0, 0, 0, 2]), \
                 patch.object(collector.time, "sleep"):
                collector.main(["--duration", "1", "--output", str(output)])
            self.assertEqual(output.stat().st_mode & 0o777, 0o600)
            self.assertEqual(len(output.read_text().splitlines()), 1)
            self.assertEqual(json.loads(output.read_text())["processes"], [])
            with self.assertRaises(FileExistsError):
                collector.main(["--output", str(output)])

    def test_invalid_capture_bounds(self):
        for arguments in [["--duration", "0"], ["--duration", "601"], ["--interval", "0"], ["--interval", "nan"]]:
            with self.subTest(arguments=arguments), self.assertRaises(SystemExit):
                collector.main(arguments)


if __name__ == "__main__":
    unittest.main()

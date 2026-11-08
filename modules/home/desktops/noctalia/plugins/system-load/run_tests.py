"""Run mock-host behavior tests with a Luau interpreter (no desktop required)."""

import argparse
import json
from pathlib import Path
import subprocess
import tempfile


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--luau", default="luau", help="Luau interpreter executable")
    args = parser.parse_args()
    root = Path(__file__).parent
    loader = """local modules, loaded = {}, {}
function require(id)
  if loaded[id] ~= nil then return loaded[id] end
  assert(modules[id], "Unknown test module: " .. id)
  local result = modules[id]()
  loaded[id] = result == nil and true or result
  return loaded[id]
end
"""
    for module in sorted(root.glob("*.luau")):
        if not module.name.startswith("test_"):
            loader += f"modules[{json.dumps('./' + module.name)}] = function()\n{module.read_text()}\nend\n"
    with tempfile.TemporaryDirectory(prefix="noctalia-load-tests-") as directory:
        for name in ("test_model.luau", "test_plugin.luau"):
            script = Path(directory) / name
            script.write_text(loader + "\n" + (root / name).read_text())
            subprocess.run([args.luau, str(script)], check=True)


if __name__ == "__main__":
    main()

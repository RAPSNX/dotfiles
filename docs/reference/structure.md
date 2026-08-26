## 🏛️ Structure

### `flake.nix`
- `NixOS` and `HomeManager` configurations.

### `devshells.nix`
- `devShells` to provide `git-commit-hooks` for:
    - Leverage git-commit-hooks with enforce of lint, fmt & code checking.
    - Shell environment with all tools needed to switch, build & run the `flake`.

### `hosts/*`
- All devices using nix, with the host specific module configuration:
    - `default.nix` entrypoint and config for all `NixOS` modules, usually imports the `hardware-configuration.nix`.
    - `home.nix`entrypoint and config for all `home-manager` modules.

### `modules`
- All modules for `home-manager` and `NixOS`

**Module structure**

- It defines a `option` and `config` for it.
- Modules are organized into clean 2-level category files (e.g. `cli/atuin.nix`, `browsers/firefox.nix`) and discovered automatically.


### `extra/`

Configuration or backup files mostly not directly related to `nix`.


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
- Every module has a `default.nix` which imports all module related files.


### `extra/`

Configuration or backup files mostly not directly related to `nix`.


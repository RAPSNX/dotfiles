## 🏛️ Structure

# TODO: Update this completly

- **`flake.nix`** Entrypoint to all:
    - `NixOS` configurations.
    - `HomeManager` configurations.
    - `devShells` to provide `nix develop` environment. (see `shell.nix`)
    - `formatter`.
- **`shell.nix`** Shell config for `nix develop` environment.
    - Leverage git-commit-hooks with enforce of lint, fmt & code checking.
    - Shell environment with all tools needed to switch, build & run the `flake`.
- **`hosts/`** All physical machines managed by `NixOS`.
- **`nixos`** Modules for `NixOS` separated into:
    - `common/` **default** configurations for all `hosts`.
    - `*` optional to import.
- **`home-manager`** Entrypoint for all `home-configurations` per `host`.
    - `common/` contains configuration defaults valid for all `home-configurations`.
    - `*/` contains `NixOS` modules, optional to import.
- `isos/` Configuration for all `NixOS` configurations which build images.
- `extra/` Configuration or backup files mostly not directly related to `nix`.
- `nix.nix` Nix & nixpkgs configuration for `NixOS` & `HomeManager`.

## 📜 Rules

- **`Host`**
  - ⚖️ Every `hosts` entrypoint is a `default.nix`.
    - ⚖️ It imports all `NixOS` modules as `path`.
    - ⚖️ Define *host specific configuration*
    - ⚖️ Imports `hardware-configuration.nix`
  - May has a `disko.nix` configuration to configure `filsystems`.
- **`Home-manager`**
  - ⚖️ Every `host` has its own entrypoint at toplevel.
  - ⚖️ Every `host` entrypoint is a file with the host name which:
    - Imports all `Home` configuration for this `host`.
    - Defines **host specific configuration**


// TODO: Define structure
- `Module` design
  - `option.nix`
  - `default.nix`
  - `imports = []`

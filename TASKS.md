# Phased Implementation Plan (`feat/noctalia-shell`)

# Phase 1: Critical Bug Fixes (Fix the most, change the least)
*Severity: Critical / Blocker — Resolves active session freezes, display crashes, and desktop environment pollution with minimal, surgical changes.*

- [x] Fix Nextcloud logout portal crash trigger
  - [x] Type: Bug Fix | Severity: Blocker | Files: `modules/home/services/nextcloud.nix`
  - [x] Add `systemd.user.services.nextcloud-client.Service.ExecStop = lib.mkForce [ ];`
  - [x] Prevent `nextcloud --quit` from launching a displayless Qt process during logout that invokes the GTK portal
  - [x] Rely on systemd standard signal termination (`SIGTERM`) for Nextcloud client processes
- [x] Isolate Noctalia systemd service from GNOME sessions
  - [x] Type: Bug Fix | Severity: Blocker | Files: `modules/home/desktops/noctalia/default.nix`
  - [x] Change `Install.WantedBy` from `[ "graphical-session-pre.target" ]` to `[ "hyprland-session.target" ]`
  - [x] Guard custom Noctalia systemd integration on Hyprland role enablement (`config.roles.desktop.hyprland.enable`)
  - [x] Retain existing `Type = "dbus"`, `BusName`, `Before = [ "graphical-session-pre.target" ]`, and `PartOf = [ "hyprland-session.target" ]`
  - [x] Do NOT restore Home Manager's default `After = [ "graphical-session.target" ]` to prevent cyclic ordering
- [x] Isolate Kanshi display profile service to Hyprland
  - [x] Type: Bug Fix | Severity: Major | Files: `modules/home/desktops/addons/kanshi/default.nix`
  - [x] Set `services.kanshi.systemdTarget = "hyprland-session.target"`
  - [x] Prevent Kanshi from failing repeatedly inside GNOME Wayland where `wlr-output-management` is unavailable
- [x] Fix global autostart masks breaking GNOME fallback
  - [x] Type: Bug Fix | Severity: Major | Files: `modules/home/desktops/noctalia/default.nix`, `hosts/firefly/home.nix`
  - [x] Remove global `Hidden=true` stubs for `nm-applet`, `blueman`, and `update-notifier` from Noctalia module
  - [x] In `hosts/firefly/home.nix`, define proper desktop entry overrides utilizing `NotShowIn = [ "Hyprland" ];`
  - [x] Preserve executable paths and native KDE/GNOME exclusion metadata for Ubuntu's Update Notifier and nm-applet

# Phase 2: Service Duplication & Conflict Resolution
*Severity: High / Major — Eliminates competing daemons, duplicate socket listeners, and redundant routing rules.*

- [x] Remove duplicate Home Manager gnome-keyring daemon
  - [x] Type: Conflict Resolution | Severity: High | Files: `modules/home/services/keyring.nix`
  - [x] Remove automatic `services.gnome-keyring.enable = true` assignment on generic Linux
  - [x] Clean up newly unused module arguments in `keyring.nix`
  - [x] Let Ubuntu host PAM and socket activation manage `gnome-keyring-daemon` exclusively
  - [x] Retain client utility packages (`seahorse`, `gcr`) in user profile
- [x] Drop redundant portal default configuration
  - [x] Type: Cleanup | Severity: Medium | Files: `hosts/firefly/home.nix`
  - [x] Remove redundant `hyprland.default` portal table (duplicates upstream Hyprland defaults)
  - [x] Remove redundant `gnome.default` portal table (duplicates Ubuntu GNOME defaults)
  - [x] Remove global `common.default` portal override (avoids routing external sessions to Hyprland)
- [x] Verify polkit authorization agent status
  - [x] Type: Audit | Severity: Medium | Files: `hosts/firefly/home.nix`
  - [x] Test GUI privilege escalation (e.g. `pkexec` or system settings) to verify if an active polkit agent is required
  - [x] Document whether Ubuntu's GNOME polkit agent is active or if a lightweight agent should be restored
  - [x] Restored Noctalia's native polkit agent in `hosts/firefly/home.nix` by removing `polkitAgent = false;` override

# Phase 3: Declarative Migration & Architecture Alignment
*Severity: Medium / Improvement — Migrates imperative files to standard Home Manager options and encapsulates generic-Linux packaging.*

- [x] Relocate generic-Linux portal unit package ownership
  - [x] Type: Architectural Improvement | Severity: Medium | Files: `hosts/firefly/home.nix`, `modules/home/desktops/hyprland/default.nix`
  - [x] Move `systemd.user.packages` entries (`xdg-desktop-portal`, `xdg-desktop-portal-gtk`, `xdg-desktop-portal-hyprland`) from host config to reusable Hyprland module
  - [x] Guard package unit registrations behind `isGenericLinux` and `!config.hostConfig.configOnly`
  - [x] Keep host-specific GDM session desktop registration and custom autostart in `hosts/firefly/home.nix`
- [x] Migrate handwritten XDPH configuration to Home Manager options
  - [x] Type: Declarative Migration | Severity: Medium | Files: `modules/home/desktops/hyprland/default.nix`
  - [x] Migrate handwritten `~/.config/hypr/xdph.conf` to `wayland.windowManager.hyprland.xdph.settings`
  - [x] Configure `screencopy.cursor_mode = 2` (embedded cursor)
  - [x] Configure `screencopy.allow_token_by_default = true` (picker restore-token convenience)
  - [x] Configure `screencopy.max_fps = 60` (caps 4K 240Hz screen capture work to 60 FPS)
  - [x] Leave `force_shm` unset initially to preserve native DMA-BUF negotiation
  - [x] Delete obsolete handwritten `xdph.conf` file
- [x] Migrate handwritten PATH environment configuration
  - [x] Type: Declarative Migration | Severity: Low | Files: `modules/home/desktops/hyprland/default.nix`
  - [x] Express `environment.d` PATH entries via `systemd.user.sessionVariables.PATH`
  - [x] Delete obsolete handwritten `environment.d` files
- [x] Narrow environment variable import scope
  - [x] Type: Improvement | Severity: Low | Files: `modules/home/desktops/hyprland/default.nix`
  - [x] Replace broad `variables = [ "--all" ];` with explicit display/session variables: `DISPLAY`, `WAYLAND_DISPLAY`, `HYPRLAND_INSTANCE_SIGNATURE`, `XDG_CURRENT_DESKTOP`, `XDG_SESSION_DESKTOP`, `XDG_DATA_DIRS`, and `PATH`
- [x] Housekeeping & flake input cleanup
  - [x] Type: Housekeeping | Severity: Low | Files: `flake.nix`
  - [x] Remove unused `hyprland-git` flake input from `flake.nix` and `flake.lock`

# Phase 4: Big Changes & Deep Performance Investigation
*Severity: Low / Experimental — Substantial changes or investigations that require benchmarking, diagnostic tools, and controlled testing.*

- [x] Investigate 4K screencopy DMA-BUF vs forced SHM performance
  - [x] Type: Deep Investigation | Severity: Experimental | Files: `modules/home/desktops/hyprland/default.nix`
  - [x] Reproduce journal errors: `DMA-BUF fixation failed after 2 attempts, falling back to SHM` and `tried scheduling on already scheduled cb`
  - [x] Run controlled capture comparison: Automatic negotiation vs `force_shm = true` under 4K 240Hz screen sharing
  - [x] Measure CPU utilization, PipeWire memory overhead, and frame drops using `pw-top` and WebRTC diagnostics
  - [x] Decide whether to permanently enable `force_shm = true` or retain automatic fallback (Decision: retain native automatic fallback with `max_fps = 60` cap, leave `force_shm` unset)
- [x] Refactor documentation and rollback procedures
  - [x] Type: Documentation | Severity: Low | Files: `docs/hosts/firefly.md`
  - [x] Update `docs/hosts/firefly.md` with explicit Nix vs Ubuntu ownership boundaries
  - [x] Correct portal discovery documentation (clarify that modern portals discover via XDG data dirs, not `NIX_XDG_DESKTOP_PORTAL_DIR`)
  - [x] Document accurate rollback steps, explicitly including the removal of `~/.local/share/systemd/user/` package units

# Phase 5: Verification, Validation & Acceptance Criteria
*Severity: Quality Assurance — Formal testing gates before declaring complete resolution.*

- [x] Flake evaluation and linting
  - [x] Type: QA / Evaluation | Severity: Required
  - [x] Evaluate Firefly home configuration: `nix eval .#homeConfigurations."nix@firefly".activationPackage`
  - [x] Ensure zero assertion failures and zero Home Manager warnings
  - [x] Format code using `nix fmt`
  - [x] Run linters: `statix check .` and `deadnix .`
- [x] Build verification
  - [x] Type: QA / Build | Severity: Required
  - [x] Build target: `nh home build -c nix@firefly .` (or `home-manager build --flake .#nix@firefly`)
  - [x] Inspect generated systemd user units under `result/home-files/.local/share/systemd/user/`
- [ ] Session lifecycle and relogin acceptance testing
  - [ ] Type: QA / Runtime | Severity: Required
  - [ ] Test fresh Hyprland login: confirm Noctalia acquires `StatusNotifierWatcher` before tray applications launch
  - [ ] Test 3 consecutive logout/relogin cycles with background SSH connection to ensure graphical targets stop and start cleanly
  - [ ] Verify complete absence of `cannot open display` GTK portal errors and Settings D-Bus timeouts in `journalctl --user`
  - [ ] Test Nextcloud shutdown: confirm no new Qt process launches and pending sync operations resume safely
- [ ] Fallback desktop acceptance testing
  - [ ] Type: QA / Runtime | Severity: Required
  - [ ] Log into Ubuntu GNOME session: verify Noctalia and Kanshi remain completely stopped
  - [ ] Verify GNOME system tray, nm-applet, update-notifier, and bluetooth applet function normally
  - [ ] Switch back to Hyprland: verify clean environment restoration

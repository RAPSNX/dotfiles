# Review of `feat/noctalia-shell` and minimal implementation plan

The Nix/Ubuntu package split is broadly correct. Keep the package-provided portal services and Noctalia’s D-Bus readiness mechanism.

The justified changes are narrower: isolate Hyprland services from GNOME, remove an observed Nextcloud shutdown trigger, replace redundant portal configuration with upstream defaults, and investigate the capture failures already present in the journal.

## 1. Current architecture

Reviewed pushed commit [`875cdf42`](https://github.com/RAPSNX/dotfiles/commit/875cdf42f3779e5e3d7ed4dd7f5279a26c39ede8), confirmed against GitHub twice. The local checkout and active generation differ from that revision; runtime observations below are identified separately from findings about the pushed configuration.

The pushed Firefly configuration evaluates successfully, with all assertions passing and no Home Manager warnings.

| Component | Pushed configuration / actual ownership |
|---|---|
| Home Manager | `693e8ce0fb240a73c116a03cfd7b19269c87af88` |
| Root Nixpkgs | `3ed67ec0a4d3c7ab4ae1f04f8ee8df07bfa506a2` |
| Hyprland | Nixpkgs **0.56.2** |
| Portal frontend | Nixpkgs **1.22.1** |
| XDPH | Nixpkgs **1.4.1**, using HM’s `finalPortalPackage` |
| GTK portal | Nixpkgs **1.15.3** |
| Noctalia | **5.0.1**, input revision `55e7b458…`, with its own Nixpkgs pin |
| PipeWire client libraries | Root Nixpkgs **1.6.8** |
| Running PipeWire server | Ubuntu/PPA **1.2.4** |
| Running WirePlumber | Ubuntu **0.4.17** |
| GNOME portal | Ubuntu **46.2** |
| Running user systemd | Ubuntu **255.4**, despite Nix providing a newer `systemctl` |

The `hyprland-git` input is **unused by the configuration**. Its Hyprland and XDPH revisions do not describe the installed compositor stack.

GDM launches the generated `start-hyprland` desktop entry. Home Manager generates:

```text
import environment into D-Bus and systemd
    → stop previous hyprland-session.target
    → start hyprland-session.target

Noctalia acquires StatusNotifierWatcher
    → graphical-session-pre.target
    → graphical-session.target
    → graphical applications

hyprland-session.target
    → xdg-desktop-autostart.target
```

The portals activate through D-Bus. `systemd.user.packages` exposes Nix package units under `~/.local/share/systemd/user`, overriding Ubuntu’s same-named units.

Consequently, GNOME fallback uses the **Nix frontend and GTK backend**, with Ubuntu’s GNOME backend. It remains an Ubuntu desktop session, but its portal stack is not independent of the user’s Nix configuration.

## 2. What is already correct

| Finding | Classification | Evidence and effect |
|---|---|---|
| Explicit portal `systemd.user.packages` | **No change needed** | The pinned HM portal module installs packages and configuration, but does **not** install their user units. These entries are necessary on Ubuntu. |
| Using `finalPortalPackage` | **No change needed** | HM applies the effective Hyprland package to XDPH’s dependencies. Keep this rather than substituting the raw package. |
| Nix frontend discovers Ubuntu GNOME descriptors | **No change needed** | Frontend 1.22.1 searches `XDG_DATA_HOME`, `XDG_DATA_DIRS`, then its compiled data directory. Generic Linux integration includes both the Nix profile and `/usr/share`. |
| D-Bus activation ownership | **No change needed** | Both distributions’ activation files name the same `SystemdService`. The selected user unit determines the executable; installing both packages does not inherently launch two frontends. |
| Hyprland target dependencies | **No change needed** | HM already supplies `BindsTo=graphical-session.target`, `PropagatesStopTo=graphical-session.target`, and the pre-session/autostart ordering. |
| Standard portal lifecycle dependencies | **No change needed initially** | Frontend already has `PartOf`, `Requisite`, and `After` for `graphical-session.target`. GTK has `PartOf`/`After`; XDPH additionally checks `WAYLAND_DISPLAY`. |
| Noctalia `Type=dbus` | **No change needed** | The pinned implementation exports `/StatusNotifierWatcher` before claiming `org.kde.StatusNotifierWatcher`. This is a real readiness signal. |
| Ubuntu PipeWire server with Nix clients | **No change needed solely because versions differ** | They communicate across the PipeWire protocol. The running Noctalia successfully connects with client library 1.6.8 to server 1.2.4. This does not, by itself, certify every capture path. |

Relevant source: [pinned HM portal module](/nix/store/h2ijjnwi5740n0qdwyksxr8bh880h2yp-source/modules/misc/xdg/portal.nix), [portal discovery implementation](/nix/store/xg7q905740havgfv7mynvwdpmvmk138p-source/src/xdp-portal-config.c:344), and [Noctalia watcher registration](/nix/store/s32z8cgrs119c2rg5b4vr9aghygwwqvv-source/src/dbus/tray/tray_service.cpp:618).

`After=` supplies ordering, not activation or proof of a working display. `PartOf=` propagates stop/restart, but does not restrict where a service may start. `Requisite=` checks another unit’s state; it does not establish compositor readiness. These distinctions matter to the remaining findings.

## 3. Bugs or races found

### A. Noctalia is enabled for GNOME startup

**Classification: correctness issue. Confirmed from generated dependencies.**

[Noctalia configuration](/home/raphaelgroemmer/Projects/rapsnx/dotfiles/modules/home/desktops/noctalia/default.nix:230) combines:

```ini
PartOf=hyprland-session.target
Before=graphical-session-pre.target
WantedBy=graphical-session-pre.target
```

Ubuntu GNOME also starts `graphical-session-pre.target`. Therefore it pulls in Noctalia. `PartOf=hyprland-session.target` does not prevent this.

Possible consequences include failed Wayland-shell startup, readiness delays, and contention with GNOME’s notification/tray services.

**Smallest correction:** change only the installation target to `hyprland-session.target`, preserving the early ordering and D-Bus readiness. Apply this custom integration only when the Hyprland role is enabled.

Do **not** restore HM’s default `After=graphical-session.target`: that would conflict with the existing early ordering.

### B. The GTK failure has an observed logout trigger

**Classification: correctness issue. Historical failure confirmed; complete resolution by the pushed state is not demonstrated.**

The journal shows this sequence twice, at approximately **21:53:40** and **21:56:29 on September 7**:

1. Hyprland’s display disappears.
2. The graphical services begin stopping.
3. Nextcloud’s generated `ExecStop=nextcloud --quit` launches another Qt process.
4. That process requests `org.freedesktop.portal.Desktop` through D-Bus.
5. The frontend and GTK backend start during teardown.
6. GTK reports `cannot open display`.
7. Other recorded occurrences continue into Settings proxy timeouts and frontend startup timeouts.

The shutdown command comes from the pinned [Home Manager Nextcloud module](/nix/store/h2ijjnwi5740n0qdwyksxr8bh880h2yp-source/modules/services/nextcloud-client.nix:41), enabled by [this repository module](/home/raphaelgroemmer/Projects/rapsnx/dotfiles/modules/home/services/nextcloud.nix:2).

Hyprland’s shutdown hook launches asynchronously; its cleanup also removes display variables and destroys clients. Therefore correct startup environment import does not make this shutdown path safe.

The frontend’s existing `Requisite=` prevents ordinary activation when the graphical target is already inactive. It is not sufficient evidence that teardown is safe. An open systemd report describes activation cancelling a pending stop through this dependency; that report concerns systemd 257, so it supports the mechanism without proving that exact internal bug on Ubuntu 255. [systemd issue #39409](https://github.com/systemd/systemd/issues/39409)

**Smallest proposed correction:** clear the existing Nextcloud service’s `ExecStop`, allowing systemd to terminate its existing process normally. This removes the demonstrated fresh-GUI-process trigger without adding a service or portal dependency.

This changes shutdown from Nextcloud’s application-level quit command to normal signal termination. Validate sync recovery and pending-transfer behavior explicitly.

The historical records include intermediate configurations. They establish the trigger, but cannot certify the exact final pushed generation’s relogin behavior.

### C. Global autostart masks alter GNOME fallback

**Classification: correctness issue. Confirmed.**

The [three `Hidden=true` entries](/home/raphaelgroemmer/Projects/rapsnx/dotfiles/modules/home/desktops/noctalia/default.nix:89) disable NetworkManager applet, Blueman, and Ubuntu Update Notifier in every session.

Update Notifier and Blueman consequently remain suppressed in GNOME, where Noctalia should not replace them.

Replace these with valid Firefly-specific autostart entries that exclude Hyprland using `NotShowIn`, retaining the original desktop exclusions and executable information. Merely replacing `Hidden=true` with `NotShowIn` in the current minimal stubs would leave entries without `Exec`.

### D. Kanshi is enabled for GNOME Wayland

**Classification: correctness issue. Confirmed configuration mismatch.**

[Kanshi](/home/raphaelgroemmer/Projects/rapsnx/dotfiles/modules/home/desktops/addons/kanshi/default.nix:4) targets `graphical-session.target`. Its `WAYLAND_DISPLAY` condition also succeeds in GNOME Wayland, whose compositor does not supply Kanshi’s expected output-management protocol.

Set its existing `systemdTarget` option to `hyprland-session.target`.

### E. Two keyring services are running

**Classification: architecture/maintainability improvement. Duplication confirmed.**

The [generic-Linux enablement](/home/raphaelgroemmer/Projects/rapsnx/dotfiles/modules/home/services/keyring.nix:8) assumes Home Manager must provide a keyring service on Ubuntu.

Runtime inspection found both the Ubuntu socket-activated daemon and the Nix HM daemon running. Ubuntu’s daemon owns `org.freedesktop.secrets`; the Nix process reports discovering another daemon.

Remove the automatic HM daemon enablement. Retain Ubuntu’s PAM/socket integration and the desired client packages. This is unnecessary orchestration, not evidence of two competing secret stores.

## 4. Redundant or questionable configuration

**Classification: architecture/maintainability improvements.**

- **Portal routing duplicates installed defaults.** Firefly’s `hyprland.default` reproduces the Hyprland package configuration; `gnome.default` reproduces Ubuntu’s configuration. Remove these and the global `common.default`. The latter unnecessarily selects Hyprland outside its named session. Frontend 1.22.1 supports layered configuration, so I did **not** find that the current GNOME override necessarily loses the system Secret mapping.
- **The hardcoded-discovery comment is outdated.** `NIX_XDG_DESKTOP_PORTAL_DIR` is still emitted by pinned HM, but frontend 1.22.1 does not use it. Keep HM’s behavior; stop treating that variable’s presence as a discovery test.
- **Handwritten `xdph.conf` duplicates an available HM option.** Use `wayland.windowManager.hyprland.xdph.settings`.
- **Handwritten `environment.d` is unnecessary.** Express its PATH entry through `systemd.user.sessionVariables.PATH`, preserving the existing value.
- **`variables = [ "--all" ]` is broader than necessary.** Use HM’s standard display/session variables plus `PATH`, `XDG_DATA_DIRS`, and `XDG_SESSION_DESKTOP`. This limits stale unrelated environment state; it is not the logout fix.
- **Generic-Linux portal ownership belongs with reusable Hyprland integration.** Move GTK backend installation and the three package-unit entries there, guarded by generic Linux and `!configOnly`. Keep GDM registration and Ubuntu-specific exclusions in Firefly.
- **Unused `hyprland-git` input:** harmless at runtime, but confusing when identifying versions. Remove separately as optional housekeeping.
- **Rollback documentation names obsolete service overrides.** It must describe removing the package-unit ownership entries. Disabling `xdg.portal` alone does not remove `systemd.user.packages`.

One additional correctness check: Firefly disables Noctalia’s polkit agent, and I found no running replacement agent. Interactive authorization may therefore fail. Test an operation requiring authentication before retaining that override; this was not exercised during the review.

## 5. Performance/stability opportunities

### Capture rate

**Classification: performance/stability optimization.**

The configured and running 4K display is approximately **239.991 Hz**, rather than 244 Hz.

Pinned XDPH defaults to `max_fps=120` for output/region capture. Window capture starts at 60 FPS through a separate path. PipeWire negotiation can lower the eventual rate further; desktop refresh is not automatically the WebRTC send rate.

A **60 FPS output-capture ceiling** is justified for this workload. It reduces the maximum unnecessary capture work while retaining smooth presentation. It will provide little benefit if negotiation already limits capture to 30 FPS. Measure actual capture and encoding behavior before claiming a gain.

See [pinned frame-rate selection and scheduling](/nix/store/bp6dbwl10znnlyfnyyqwm5r2a5am4pjy-source/src/portals/Screencopy.cpp:235).

### DMA-BUF versus SHM

**Classification: performance/stability investigation justified by observed failures.**

Keep automatic negotiation initially. The pinned implementation already falls back after DMA-BUF allocation/fixation failures.

However, the historical journal contains repeated:

```text
DMA-BUF fixation failed after 2 attempts, falling back to SHM
tried scheduling on already scheduled cb
```

These match symptoms in an open XDPH report involving AMD output capture and renegotiation. That report contains an unverified diagnosis; its proposed GPU workaround should not be copied into this configuration. [XDPH issue #403](https://github.com/hyprwm/xdg-desktop-portal-hyprland/issues/403)

Run a controlled comparison using the same application, output, content, and frame-rate ceiling:

- Automatic DMA-BUF/SHM negotiation.
- Temporary `force_shm=true`.
- Window capture versus whole-output capture.

Retain forced SHM only if it eliminates reproducible failures at acceptable CPU/memory cost. Do not globally disable GPU modifiers, hardware cursors, or GPU acceleration.

### Cursor, tokens, and buffers

**Classification: no change needed.**

- `cursor_mode=2` is supported by pinned 1.4.1. It sets the default embedded-cursor mode; an explicit client choice takes precedence. Metadata cursor mode is not implemented.
- `allow_token_by_default=1` changes the picker’s restore-token default. It is a convenience setting, not a throughput optimization or a way to preserve streams across logout.
- XDPH requests four buffers by default, negotiating within a 2–32 range. There is no justification for custom buffer-count patches or PipeWire audio-quantum tuning.
- Do not add Chromium feature switches without a demonstrated issue. Measure capture, scaling, and encoding separately.

Version 1.4.1 already includes a fix for loop-hangup CPU consumption and the cursor-default option. Its predecessor also contains lifetime fixes. Reapplying older workarounds would be redundant. [1.4.1 release](https://github.com/hyprwm/xdg-desktop-portal-hyprland/releases/tag/v1.4.1), [1.4.0 release](https://github.com/hyprwm/xdg-desktop-portal-hyprland/releases/tag/v1.4.0)

## 6. Recommended target state

Preserve the current ownership model:

- Ubuntu owns GDM/GNOME, PAM/keyring, PipeWire/WirePlumber, and the GNOME portal backend.
- Nix owns Hyprland, Noctalia, the frontend, GTK backend, and XDPH.
- Home Manager owns the standard Hyprland target, environment import, and XDG autostart integration.
- Noctalia is pulled in only by Hyprland, while its watcher readiness still precedes graphical application startup.
- Portal activation remains D-Bus driven, using unmodified package units.
- Nextcloud no longer launches a new GUI process during service teardown.

Noctalia’s automatic restart remains `on-failure`. Restarting it should not restart the graphical session or tray applications. Its source includes existing-item discovery, but arbitrary applications that mishandle watcher replacement cannot be guaranteed to recover without application fixes.

Do not introduce UWSM, a portal supervisor, per-tray-app dependencies, or sleeps in this change.

## 7. Ordered implementation plan

1. Correct Noctalia and Kanshi session scope; restore GNOME-compatible autostart behavior.
2. Remove redundant HM keyring daemon ownership.
3. Remove Nextcloud’s observed shutdown activation trigger.
4. Evaluate and build only `nix@firefly`; inspect generated units and run lifecycle tests.
5. Consolidate portal configuration and migrate handwritten configuration to existing HM options.
6. Add the 60 FPS output-capture ceiling and perform the controlled capture tests.
7. Update ownership, rollback, and troubleshooting documentation.
8. If lifecycle failures remain, capture their activation caller and exact target state before proposing additional dependencies.

The normal-logout fix must not be described as crash supervision: HM’s configuration hook cannot guarantee cleanup when the compositor is forcibly killed or bypasses its normal exit path.

## 8. Exact files/options to change

| File | Concrete change |
|---|---|
| `modules/home/desktops/noctalia/default.nix` | Change `Install.WantedBy` to `[ "hyprland-session.target" ]`; guard the custom integration on Hyprland enablement. Preserve `Type`, `BusName`, empty `After`, existing `Before`, and `PartOf`. Remove global autostart masks. |
| `modules/home/desktops/addons/kanshi/default.nix` | Set `services.kanshi.systemdTarget = "hyprland-session.target"`. |
| `modules/home/services/keyring.nix` | Remove automatic `services.gnome-keyring.enable` assignment and newly unused arguments. Preserve client packages. |
| `modules/home/services/nextcloud.nix` | Add `systemd.user.services.nextcloud-client.Service.ExecStop = lib.mkForce [ ];` to the existing module. Preserve its startup behavior and other dependencies. |
| `modules/home/desktops/hyprland/default.nix` | Use `xdph.settings.screencopy` with `cursor_mode = 2`, `allow_token_by_default = true`, `max_fps = 60`; leave `force_shm` unset. Use HM’s systemd environment option and an explicit import list. Add guarded generic-Linux portal package ownership. |
| `hosts/firefly/home.nix` | Remove duplicated portal routing and relocated ownership entries. Define valid Ubuntu autostart replacements excluding Hyprland: retain KDE/GNOME exclusions for nm-applet and KDE exclusion for update-notifier. Preserve GNOME’s existing update-notifier metadata. |
| `docs/hosts/firefly.md` | Document actual ownership, standard XDG discovery, GPU setup/update verification, and accurate rollback steps. |

The service-scope, keyring-disablement, and cleared-`ExecStop` changes were evaluated **in memory** against the pushed revision; assertions passed. No configuration files were edited or activated.

## 9. Configuration to remove

Remove:

- Noctalia’s global pre-session enablement.
- The three global `Hidden=true` masks.
- The redundant HM keyring daemon enablement.
- Nextcloud’s generated GUI `ExecStop` invocation.
- Firefly’s three explicit portal default mappings.
- Handwritten XDPH and PATH files after migrating them to HM options.
- Obsolete discovery and rollback claims.

Keep:

- All three portal package-unit registrations.
- GTK portal installation.
- HM-generated Hyprland target dependencies.
- Noctalia’s D-Bus readiness and early ordering.
- Ubuntu portal packages and GNOME fallback session.
- Default DMA-BUF negotiation and buffer handling.

## 10. Runtime tests and acceptance criteria

Already checked: pushed Firefly evaluation/assertions, installed unit verification, active watcher ownership, and a successful Settings read. No logout, GNOME login, restart, or capture test was performed.

| Scenario | Acceptance criterion |
|---|---|
| Fresh Hyprland login | Noctalia owns the watcher before tray application processes start; no ordering cycles or portal timeouts. |
| Three logout/relogin cycles with an SSH session keeping the user manager alive | Graphical targets stop between sessions; new processes receive the new display environment; no displayless GTK launch or Settings timeout. |
| Noctalia restart | Watcher returns, existing tray items recover, application PIDs remain unchanged, graphical targets remain active. |
| Hyprland → GNOME → Hyprland | Noctalia and Kanshi remain stopped in GNOME; GNOME notifications, keyring, update notifier, file chooser, and screen sharing work. |
| Nextcloud shutdown/relogin | No fresh Qt process launches from `ExecStop`; interrupted transfers resume without sync-database errors. |
| Portal ownership | One frontend bus owner; Nix frontend/GTK/XDPH units; Ubuntu GNOME backend selected only where appropriate. |
| 4K capture for 30–60 minutes | Stable stream and memory use; no accumulating callbacks, repeated renegotiation failure, or frozen frames. |
| Capture transitions | Exercise window resize, fullscreen enter/exit, stop/start, and output reconnect; record negotiated FPS and buffer type. |
| GNOME authorization | A GUI operation requiring authentication displays a working prompt. |
| Compositor failure/reboot | Record whether the normal hook runs and whether targets remain active; treat failures separately from ordinary logout. |

Useful read-only probes:

```sh
systemctl --user cat hyprland-session.target noctalia.service \
  xdg-desktop-portal.service xdg-desktop-portal-gtk.service \
  xdg-desktop-portal-hyprland.service

systemctl --user show-environment |
  rg '^(DISPLAY|WAYLAND_DISPLAY|HYPRLAND_INSTANCE_SIGNATURE|XDG_CURRENT_DESKTOP|XDG_DATA_DIRS)='

busctl --user --auto-start=no --timeout=5s call \
  org.freedesktop.portal.Desktop /org/freedesktop/portal/desktop \
  org.freedesktop.portal.Settings Read ss \
  org.freedesktop.appearance color-scheme
```

Use `pw-top`, PipeWire node inspection, Chromium’s WebRTC diagnostics, and timestamped journals during capture tests. Build additional hosts only with the repository-required confirmation.

Assumption: fallback means sequential desktop sessions for the same user. Simultaneous GNOME and Hyprland sessions share the user manager and D-Bus names and are outside this minimal target state.

# Backups

1. Firefox profile

```bash
# TODO: Add this to home.nix
rsync -av --update  ~/.mozilla/firefox/default ~/Nextcloud/Home/Backups/firefox_profile/
```

2. Check atuin `key` match with the key in vault.

# System Architecture & Ownership Boundaries

Firefly operates on Ubuntu with Home Manager managing the desktop environment for user `raphaelgroemmer`. To ensure stability and seamless GNOME fallback, responsibilities are cleanly divided:

| Subsystem | Managed by | Description |
|---|---|---|
| Display Manager & Session Base | Ubuntu | GDM, PAM authentication, `/usr/share/wayland-sessions/` |
| Fallback Desktop | Ubuntu | GNOME Shell, `xdg-desktop-portal-gnome`, Ubuntu Update Notifier, Blueman |
| Audio & Media Server | Ubuntu | PipeWire server, WirePlumber daemon, ALSA/Pulse integration |
| Keyring & Secrets | Ubuntu | PAM/socket-activated `gnome-keyring-daemon` owning `org.freedesktop.secrets` |
| Primary Compositor | Nix (HM) | Hyprland compositor package, layout, keybindings, window rules |
| Desktop Shell | Nix (HM) | Noctalia shell bound strictly to `hyprland-session.target` with D-Bus readiness |
| Display Management | Nix (HM) | Kanshi display profiles bound strictly to `hyprland-session.target` |
| Portals (Hyprland) | Nix (HM) | `xdg-desktop-portal` frontend, GTK backend, and XDPH (`xdg-desktop-portal-hyprland`) |
| Background Sync | Nix (HM) | Nextcloud client (terminated cleanly via standard `SIGTERM` on logout) |

# Install device
1. Install `nix` (May disable any VPN)

```bash
Verify command on nixos.org/download
sh <(curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install) --daemon
```

2. Clone dotfiles
  1. Change username `home.nix`, if necessary.
3. Switch config via `devshells` target.

```bash
nix develop
sw-fly
```

4. Install the Nix Hyprland GDM session.

Home Manager manages the **Hyprland (Nix)** userspace session, including
Hyprland and its portals. GDM reads sessions from `/usr/share`, so install the
Home Manager-generated desktop file after switching the configuration:

```bash
sudo install -m 0644 \
  ~/.local/share/wayland-sessions/hyprland-nix.desktop \
  /usr/share/wayland-sessions/hyprland-nix.desktop
```

The fallback session is the standard Ubuntu / GNOME session provided by the system.

5. Copy user-certificate to firefox

```bash
# TODO: Add this to home.nix (as activation script for example)
ln -sf ~/.pki/nssdb/* ~/.mozilla/firefox/default/
```

## Manual things

### Disable gpg-agent
```
systemctl --user mask --now gpg-agent.service gpg-agent.socket \
  gpg-agent-ssh.socket gpg-agent-extra.socket gpg-agent-browser.socket
```

### Chromium

Extension: `Open in firefox`:

**Other Settings**

- Enable Reverse Mode

**Automation Rules**

Comma-separated list of URLs:
```
*://*.google.com/*, *://chat.ske.eu01.stackit.cloud/*
```

### GTK Theme

`nwg-look` is used to configure theme in multiple locations.
Run it, ensure to remove the check of `GTK4` files in preferences.
Set `widgets -> colorScheme -> prefer dark`.

```bash
dconf read /org/gnome/desktop/interface/gtk-theme # Read the actual name
```

## Installed via APT

Those programs are installed via APT because they require host integration or
PAM integration that is not managed within Home Manager:

```bash
sudo apt -y install \
  xdg-desktop-portal \
  xdg-desktop-portal-gtk \
  mumble \
  swaylock \
  podman
```

## Verifying the Nix Hyprland Session

Verify the Nix session after switching:

```bash
# 1. Verify compositor binary is provided by Nix store
readlink -f "$(command -v Hyprland)"

# 2. Inspect active portal units and verify they resolve to Nix store packages
systemctl --user cat xdg-desktop-portal.service \
  xdg-desktop-portal-gtk.service \
  xdg-desktop-portal-hyprland.service

# 3. Test portal communication (Settings read should succeed promptly)
busctl --user --auto-start=no --timeout=5s call \
  org.freedesktop.portal.Desktop /org/freedesktop/portal/desktop \
  org.freedesktop.portal.Settings Read ss \
  org.freedesktop.appearance color-scheme

# 4. Check user systemd environment
systemctl --user show-environment | rg '^(DISPLAY|WAYLAND_DISPLAY|HYPRLAND_INSTANCE_SIGNATURE|XDG_CURRENT_DESKTOP|XDG_SESSION_DESKTOP|XDG_DATA_DIRS|PATH)='
```

### Portal Discovery Note
Modern `xdg-desktop-portal` (>= 1.17) discovers available backends through standard XDG data directories (`XDG_DATA_HOME`, `XDG_DATA_DIRS`, and `/usr/share`) via `.portal` definitions. The legacy `NIX_XDG_DESKTOP_PORTAL_DIR` environment variable is no longer used by upstream portal frontends for backend lookup.

### GPU & Driver Verification
Generic Linux OpenGL/Vulkan acceleration is enabled via `targets.genericLinux.gpu.enable = true`:
```bash
# Verify GPU driver link and Vulkan ICD discovery
ls -l ~/.nix-profile/lib/dri
vulkaninfo --summary 2>/dev/null | grep -E "deviceName|driverName"
```

## Screen Locking

Firefly uses the Ubuntu-managed `/usr/bin/swaylock`, rather than a Nix-built
locker.
Verify the native locker after switching:

```bash
readlink -f /usr/bin/swaylock
/usr/bin/swaylock --version
test -r /etc/pam.d/swaylock

# For testing, use a autounlock as fallback
sleep 15 && loginctl unlock-session self
```

## Reverting to PPA Hyprland

If you need to switch back to the PPA-provided Hyprland and host portal stack:

1. **Re-add PPA and install packages**:
   ```bash
   sudo add-apt-repository ppa:cppiber/hyprland
   sudo apt update
   sudo apt -y install hyprland xdg-desktop-portal-hyprland hyprlock
   ```

2. **Revert Home Manager configuration** in `hosts/firefly/home.nix`:
   - Set `roles.desktop.hyprland.configOnly = true;` under `roles.desktop.hyprland`.
   - Switch Home Manager:
     ```bash
     nix develop
     sw-fly
     ```

3. **Clean up Home Manager package unit symlinks**:
   Home Manager registers Nix portal units via `systemd.user.packages` which creates symlinks under `~/.local/share/systemd/user/`. To ensure systemd falls back to host `/usr/lib/systemd/user/` definitions, remove any lingering portal unit symlinks:
   ```bash
   rm -f ~/.local/share/systemd/user/xdg-desktop-portal*.service
   systemctl --user daemon-reload
   ```

4. **GDM Session**:
   - APT installs `/usr/share/wayland-sessions/hyprland.desktop` automatically.
   - Remove `/usr/share/wayland-sessions/hyprland-nix.desktop` if no longer used:
     ```bash
     sudo rm -f /usr/share/wayland-sessions/hyprland-nix.desktop
     ```

5. **Verify**:
   - `readlink -f "$(command -v Hyprland)"` resolves to `/usr/bin/Hyprland`.
   - Portal services (`systemctl --user status xdg-desktop-portal*`) run from `/usr/libexec` rather than `/nix/store`.

## Rolling Back Home Manager Generations

If a flake update or configuration change breaks the desktop environment or user services, you can roll back to a previously working Home Manager generation.

1. **List available generations**:
   ```bash
   home-manager generations
   ```

2. **Activate a specific generation**:
   Using the path output by the generations listing:
   ```bash
   ~/.local/state/nix/profiles/home-manager-<ID>-link/activate
   ```

3. **Restore Flake Lock (if broken by `nix flake update`)**:
   ```bash
   git checkout flake.lock
   sw-fly
   ```


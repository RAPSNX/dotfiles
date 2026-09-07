# Backups

1. Firefox profile

```bash
# TODO: Add this to home.nix
rsync -av --update  ~/.mozilla/firefox/default ~/Nextcloud/Home/Backups/firefox_profile/
```

2. Check atuin `key` match with the key in vault.

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

Verify the Nix session after switching:

```bash
readlink -f "$(command -v Hyprland)"
systemctl --user cat xdg-desktop-portal*.service
systemctl --user show-environment | grep NIX_XDG_DESKTOP_PORTAL_DIR
find ~/.config/xdg-desktop-portal ~/.nix-profile/share/xdg-desktop-portal -maxdepth 3 -type f 2>/dev/null
```

Expected results in **Hyprland (Nix)**:

- `Hyprland` resolves into `/nix/store`.
- Portal services use Nix store binaries rather than `/usr/libexec`.
- `NIX_XDG_DESKTOP_PORTAL_DIR` is present in the user systemd environment.

The standard Ubuntu GNOME session remains the fallback desktop session if needed.

## Screen Locking

Firefly uses the Ubuntu-managed `/usr/bin/swaylock`, rather than a Nix-built
locker.
May swaylock needs to be build without PAM support and copied over.
Verify the native locker after switching:

```bash
readlink -f /usr/bin/swaylock
/usr/bin/swaylock --version
test -r /etc/pam.d/swaylock

# For testing, use a autounclock as fallback
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
   - Remove or disable `xdg.portal` and `systemd.user.services.xdg-desktop-portal*` overrides so systemd user units fall back to host `/usr/lib/systemd/user/` definitions.
   - Switch Home Manager:
     ```bash
     nix develop
     sw-fly
     ```

3. **GDM Session**:
   - APT installs `/usr/share/wayland-sessions/hyprland.desktop` automatically.
   - Remove `/usr/share/wayland-sessions/hyprland-nix.desktop` if no longer used:
     ```bash
     sudo rm -f /usr/share/wayland-sessions/hyprland-nix.desktop
     ```

4. **Verify**:
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


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
switch-firefly
```

4. Create compositor desktop files.

`firefly` uses `roles.desktop.hyprland.configOnly = true`, so Home Manager only writes Hyprland configuration. Hyprland itself must come from the cppiber PPA and the display manager must start the APT/PPA binary directly.

```bash
echo "[Desktop Entry]
Name=Hyprland
Comment=An intelligent dynamic tiling Wayland compositor
Exec=/usr/bin/Hyprland
Type=Application" | sudo tee /usr/share/wayland-sessions/hyprland.desktop
```

`firefly` also has `roles.desktop.niri.enable = true` (PoC), backed by [niri-flake](https://github.com/sodiboo/niri-flake)'s `homeModules.niri`. Unlike Hyprland, there is no APT/PPA package for niri, so this module lets Home Manager install and manage niri itself (`programs.niri.package`, default `niri-stable` from niri-flake) in addition to generating `~/.config/niri/config.kdl` from `programs.niri.settings` (validated at build time via `niri validate`).

niri-flake has its own binary cache to avoid building niri from source. Since `firefly` doesn't use the NixOS module (which wires the cache in automatically), add it once manually:

```bash
cachix use niri
```

The display manager launches session files without the user's shell `PATH`, so the `Exec` line must use the absolute path into the Home Manager profile (`niri-session` handles systemd/portal integration, unlike calling the raw `niri` binary). `DesktopNames=niri` sets `XDG_CURRENT_DESKTOP`, which portals/theming rely on to detect the session:

```bash
echo "[Desktop Entry]
Name=Niri
Comment=A scrollable-tiling Wayland compositor
Exec=/home/$(whoami)/.nix-profile/bin/niri-session
Type=Application
DesktopNames=niri" | sudo tee /usr/share/wayland-sessions/niri.desktop
```

`niri --session` (invoked by `niri-session`) is systemd-integrated, like Hyprland — it expects `niri.service`/`niri-shutdown.target` user units to exist so GDM can track the session. Those ship inside the niri package itself, but only get linked into `~/.config/systemd/user/` automatically on NixOS; the `roles.desktop.niri` Home Manager module links them explicitly for non-NixOS hosts like `firefly` (see `modules/home/desktops/niri/default.nix`). Without that, GDM logs `Failed to start niri.service: Unit niri.service not found.` and silently falls back to another session.

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

Those programs are installed via apt, since they do not work within `nix`.

```bash
sudo add-apt-repository ppa:cppiber/hyprland
sudo apt update
sudo apt -y install \
  hyprland \
  xdg-desktop-portal \
  xdg-desktop-portal-hyprland \
  xdg-desktop-portal-gtk \
  mumble \
  swaylock \
  podman
```

Home Manager must not manage Hyprland or portal packages on `firefly`. Verify the active setup after switching:

```bash
readlink -f "$(command -v Hyprland)"
systemctl --user cat xdg-desktop-portal*.service
systemctl --user show-environment | grep NIX_XDG_DESKTOP_PORTAL_DIR
find ~/.config/xdg-desktop-portal ~/.nix-profile/share/xdg-desktop-portal -maxdepth 3 -type f 2>/dev/null
```

Expected results:

- `Hyprland` resolves to `/usr/bin/Hyprland`.
- Portal services come from the host packages, not Home Manager-generated user units.
- `NIX_XDG_DESKTOP_PORTAL_DIR` is absent from the user systemd environment.
- The `find` command does not show Home Manager-generated portal config under `~/.config/xdg-desktop-portal` or Nix profile portal definitions under `~/.nix-profile/share/xdg-desktop-portal`.

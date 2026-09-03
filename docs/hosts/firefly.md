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

4. Create Hyprland desktop file.

`firefly` uses `roles.desktop.hyprland.configOnly = true`, so Home Manager only writes Hyprland configuration. Hyprland itself must come from the cppiber PPA and the display manager must start the APT/PPA binary directly.

```bash
echo "[Desktop Entry]
Name=Hyprland
Comment=An intelligent dynamic tiling Wayland compositor
Exec=/usr/bin/Hyprland
Type=Application" | sudo tee /usr/share/wayland-sessions/hyprland.desktop
```

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

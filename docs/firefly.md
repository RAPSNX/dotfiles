# Backups

1. Firefox profile

```bash
rsync -av --update  ~/.mozilla/firefox/default ~/Nextcloud/Home/Backups/firefox_profile/
```

2. Check atuin `key` -> bitwarden

# Install device
1. Install `lix` or `nix`
2. Clone dotfiles
  1. Change username if needed in `home.nix`
3. Switch config

```bash
nh home switch -c nix@firefly . --show-activation-logs
```

4. Create `hyprland` desktop file.

```bash
echo "[Desktop Entry]
Name=Hyprland
Comment=An intelligent dynamic tiling Wayland compositor
Exec=/home/$USER/.nix-profile/bin/start-hyprland
Type=Application" | sudo tee /usr/share/wayland-sessions/hyprland.desktop
```

5. Copy user-certificate to firefox

```bash
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

`nwg-look` can be used to set the theme for multiple setting files simultanouly.
Important is that the exact theme **name** is set via `gsetting`.

`nwg-look` can be used to see what the actual name is, to persist configure it in home-manager `gtk.theme.name`.
Also `gtk.colorScheme = dark`, should enable most GTK apps to use dark by default.

```bash
dconf read /org/gnome/desktop/interface/gtk-theme # Read the actual name
```

## Installed via APT

Those programs are installed via apt, since they do not work within `nix`.

```bash
sudo apt install xdg-desktop-portal-wlr mumble
```

# Install device
1. Install it via usb-image
2. Install lix
3. Create local user
4. Get user-certificate with chandler
3. clone dotfiles
4. Make home-manager switch

```
home-manager switch --flake .#rapsn@firefly
```

## Manual things

### Disable gpg-agent
```
systemctl --user mask --now gpg-agent.service gpg-agent.socket \
  gpg-agent-ssh.socket gpg-agent-extra.socket gpg-agent-browser.socket
```

### Copy user-certificate to firefox

```bash
cp .pki/nssdb/* /home/rapsn/.mozilla/firefox/default/
```

### GTK Theme

`nwg-look` can be used to set the theme for multiple setting files simultanouly.
Important is that the exact theme **name** is set via `gsetting`.

`nwg-look` can be used to see what the actual name is, to persist configure it in home-manager `gtk.theme.name`.

```bash
dconf read /org/gnome/desktop/interface/gtk-theme # Read the actual name
```

## Outside nix 😭
- mumble (apt)
- hyprland (apt ppa:piper)
